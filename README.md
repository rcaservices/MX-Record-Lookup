# MX-Record-Lookup

This is a Bash script that reads through a CSV file and runs dig commands on the email domain field of the list to check if it is likely to bounce based upon the MX record of the email domain.

## Usage
To use the script, simply run the following command:

$ ./mxlookup.sh <input_file.csv>

Where <input_file.csv> is the CSV file you want to check for email bounces.

## Customization
The position of the email domain in the CSV file, as well as the MX domains which are likely to bounce the email, are both customizable in the script.

To edit the position of the email domain in the CSV file, simply modify the EMAIL_COLUMN variable at the top of the script to the appropriate column number (starting from 1).

To edit the list of MX domains that are likely to bounce the email, modify the BOUNCE_MX_DOMAINS array at the top of the script to include the relevant domains.

## CSV File Format
The script expects the input CSV file to have the following format:

Column 1, Column 2, ..., Email Domain, Column N
Where Email Domain is the column containing the email domains to be checked.  Each column must have a header name and at least one of the headers must have the string 'email' so that the script can display the column number for easy entry. The header row will NOT be checked by the dig command because it is required to exist for the script to work properly. 

The script outputs a new CSV file with the following format:

Column 1, Column 2, ..., Email Domain, Email LTB, Column N
Where Bounce Status is a boolean value indicating whether the email domain is "likely to bounce" (Email LTB) based on its MX record.

## Dependencies
This script requires the dig command to be installed on the system.

## License
This script is released under the MIT License. See LICENSE for details.

## Acknowledgments
This script was inspired by the need to quickly check a large list of email domains for bounces.
