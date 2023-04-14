#!/bin/bash
#
#######################

##  Variables to be used in this run of the scrub script
##

if [ $# -ne 1 ]; then
  echo "Usage: $0 <filename.csv>"
  exit 1
fi

if [ ! -f "$1" ]; then
  echo "Error: $1 does not exist"
  exit 1
fi

filename=$(basename -- "$1") # Extract filename without the path
filename="${filename%.*}" # Remove extension

# echo "Filename without extension: $filename"


File_to_check=$filename
email_domain_field=13
ADDHeaders="	DNS run date	MX domain	Email LTB"
TODAY=$(date +%Y-%m-%d)
TABVar="	"
domainname="Email"
BADMXdomains="mimecast.com|pphosted.com|ppe-hosted.com"

FIELDOUT=$(ls "$File_to_check".csv 2>/dev/null)
if [ -z "$FIELDOUT" ]
  then
    echo "The file was not found, please try again"
    exit
  else
    ########
    #  From here we have the CSV file and can proceed to process it
    #  
    ########
    ##  This line will convert the csv file to a tsv file.  
    awk -F'"' -v OFS='' '{ for (i=1; i<=NF; i+=2) gsub(",", "\t", $i) } 1'< "$File_to_check.csv" > "$File_to_check.tsv"
    HEADER=$(sed -n 1p "$File_to_check.tsv")
    NEWHEADER=$(echo "$HEADER" | tr -d '\r')
    NEWHEADER+=$ADDHeaders
    echo "$NEWHEADER" > "$File_to_check.header"

    ## Now create the header columns ready to display
    ## Get all the headers ready to display
    ROWS=$(awk 'NR > 1 {count++} END {print count}' "$File_to_check.tsv")

    ##  Display the headers, # of rows and fields
    ##
    echo "Number of Rows  :  $ROWS"
    awk -F'\t' -v domainname="$domainname" '{for(i=1;i<=NF;i++) if (index($i,domainname)) printf "%s is Column Number: %d.\n", $i, i}' "$File_to_check.tsv"

    ##  Ask for which header column that the Email Domain is found
    ##

    read -r -p "Enter the Column Number : " email_domain_field 

    ##  Create the out file, and the good file
    ##
    ## this sed command will delete the first row which is the headers for the columns.  We don't need this for the dig commands
    sed 1d "$File_to_check.tsv" > "$File_to_check.out"
    ## this command puts the headers to the $file.good file.  
    tr ',' '\t'< "$File_to_check.header" > "$File_to_check.good"
      
    ##  Now start to loop through the out file to lookup the MX domains of each entry
    ##

    arr_csv=()
    while IFS= read -r line
      do
      
        arr_csv+=("$line")
      
        DOMAIN=$(echo "$line" |awk -F'\t' -v email_domain="$email_domain_field" '{print $email_domain}' | tr -d '\r')
        echo "The company domain name is: $DOMAIN"
        sleep 2 
        ##  get the full MX domain from DNS
        ##
        MXFULL=$(dig @1.1.1.1 MX +noall +answer "$DOMAIN" | head -1 | awk '{print $6}')
        
        ##  Find if the MX domain contains the likely to bounce domains
        ##

        MX=$(echo "$MXFULL" | grep -E -v "$BADMXdomains")
        line=$(echo "$line" | tr -d '\r')
        
        if [ -z "$MX" ]; then
          line+="$TABVar"
          line+="$TODAY"
          line+="$TABVar"
          line+="$MXFULL"
          line+="$TABVar" 
          line+="TRUE"
        else
          line+="$TABVar"
          line+="$TODAY"
          line+="$TABVar" 
          line+="$MXFULL"
          line+="$TABVar"
          line+="FALSE"
        fi
        echo "$line" >> "$File_to_check.good"  
      done < "$File_to_check.out"
fi

## Clean up the good and the bad files
##
mv "$File_to_check".good{,.tsv}
rm "$File_to_check.header"
rm "$File_to_check.out"
rm "$File_to_check.tsv"
