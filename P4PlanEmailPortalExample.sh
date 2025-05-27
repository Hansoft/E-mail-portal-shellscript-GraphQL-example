#!/bin/bash

# Configuration
APIURL="http://localhost:4000/graphql"
USERNAME="mail_portal"
PASSWORD="hpmadm"

# Input: Give project ID as the first parameter.
# An e-mail message will be read from stdin.
PROJECT_ID=$1
INFILE=/tmp/$$
cat > $INFILE

function login () {
    RESULT=$(curl -s -g -X POST \
		  -H "Content-Type: application/json" \
		  -d "{\"mutation\":\"mutation login(\$loginCredentials: LoginUserInput!) {login(loginUserInput: \$loginCredentials) {access_token}\",\"variables\":{\"loginCredentials\":{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}},\"query\":\"mutation login(\$loginCredentials: LoginUserInput!) {  login(loginUserInput: \$loginCredentials) {    access_token\n  }}\"}" \
		  $APIURL)

    if ( echo $RESULT | grep -i "error" >/dev/null )
    then
	echo "Failed to log in with: $APIURL $USERNAME $PASSWORD" >&2
	echo $RESULT >&2
    else
	echo $RESULT | cut -d '"' -f 8
    fi
}

TOKEN="$(login)"

#echo Token: $TOKEN

runQuery () {
	QUERY=$1
	curl -s -g \
		-X POST \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $TOKEN" \
		-d "{\"query\":\"$QUERY\"}" \
		$APIURL >/tmp/errorlog
	cat /tmp/errorlog | sed 's/.\+id\":\"//' | cut -d '"' -f 1 
}

# E-mail parsing
BODY=`sed '1,/^\s*$/d' $INFILE`
BODY2=${BODY//$'\n'/"\\\\n"}
SUBJECT=`grep -P "Subject: " $INFILE|cut -d" " -f 2-`
ID=`echo $SUBJECT | grep -oP "^[0-9]+"` # May be empty
SENDER=$(cat $INFILE | grep "^From: " | tr ' <>' '\n\n\n' | grep @)

#echo Subject: $SUBJECT
#echo ID: $ID

set -e


if [ "$ID" == "" ]; then
	echo "Creating item: $SUBJECT"
	NEWID=$(runQuery "mutation { createBugs ( projectID:$PROJECT_ID createBugsInput: [{ name: \\\"$SUBJECT\\\" detailedDescription: \\\"$BODY2\\\" }] ) {id} }")
	mail -s "A new item $NEWID was created" $SENDER
else
	echo "Commenting on item with ID $ID"
        runQuery "mutation { postComment ( postCommentInput: { itemID:$ID text: \\\"$BODY2\\\" } ) {id} }"
	mail -s "A comment was added to item $ID" $SENDER
fi
