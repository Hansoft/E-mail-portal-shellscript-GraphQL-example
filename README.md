# E-mail-portal-shellscript-GraphQL-example
E-mail portal (shellscript GraphQL example)

An example of using shellscript with the P4 Plan GraphQL API.


## Deployment on Ubuntu:

1. Deploy P4 Plan Server and P4 Plan GraphQL API
2. Add a regular P4 Plan user for the Mail Portal.
   - Username: mail_portal. password: hpmadm
   - Edit this in P4PlanEmailPortalExample.sh if you prefer other user name/password
3. In P4PlanEmailPortalExample.sh also specify APIURL to match your deployment
4. Unzip to a folder readable by everyone (in particular: the mail group)
   - example: /opt/mailportal
5. sudo apt update
6. sudo apt install postfix
   - This is the mail server
   - Run this with default options, e.g. as a local server, for proof of concept.
   - Name example.com as the server's address
7. sudo apt install mailutils
   - This is the "mail" command line.
8. Check the user IDs for each project where you want to use this script.
    - Check IDs in ADMIN\Project in P4 Plan
    - The QA project usually has that ID + 2.
    - Example if "myproject" is ID 8472, myproject/QA will be ID: 8474
9. Add this to /etc/aliases:
  myproject "|/opt/mailportal/portal/P4PlanEmailPortalExample.sh 8474"
  otherproject "|/opt/mailportal/portal/P4PlanEmailPortalExample.sh 10142"
10. sudo newaliases

## Usage:
* Send an e-mail to myproject@example.com to create a bug in that project
  - Likewise for any other project you have listed in /etc/aliases
  - The body of the e-mail becomes the Detailed Description of the bug.
* If the subject line of your e-mail is a number, the item with that
  database ID receives the body of the e-mail as a comment.

## Troubleshooting:

* Uncomment the "echo $TOKEN" to see if a comment shows
* Consider adding "echo" statements to the script for debugging.
* Also try running curl manually with the APIURL given

* When troubleshooting or developing P4PlanEmailPortalExample.sh you will find /tmp/$$
  contains the e-mail for each run.
* /tmp/errorlog contains data

* Check /var/log/syslog for complaints from postfix.

* Example text that P4PlanEmailPortalExample.sh can take from command line:

%< ---------------------------------------------------------------- Cut here

Subject: New bug

Here is my comment.

%< ---------------------------------------------------------------- Cut here

## Implementation details:

Consider adding decoding of e-mails once INFILE is created.

Good luck!
