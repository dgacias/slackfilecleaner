#!/bin/bash
if ! which jq > /dev/null
then
        echo "jq program required, please install it: https://stedolan.github.io/jq/download/"
        exit 1
fi

#######################DEFINES#########################
#Generate your token here: https://api.slack.com/custom-integrations/legacy-tokens
TOKEN=''

#put your slack name here (example: @jsmith but without @)
MEMBER_NAME='jsmith'

# Delete files older than this:
DAYS='30'

#How many? (default 100)
COUNT='100'

# Types?
TYPES='all'
# types = 'spaces,snippets,images,gdocs,zips,pdfs'
# types = 'zips'

if [ "$TOKEN" == "" -o "$MEMBER_NAME" = "" ]
then
        echo "You need to edit your token and member name on this script."
        exit 1
fi

USERIDCOMMAND=$(echo "curl -s https://slack.com/api/users.list?token=$TOKEN | jq -r '.members[] | select(.name == \"$MEMBER_NAME\") | .id'")
USER=$(eval $USERIDCOMMAND)
TSTO=$(date --date="-$days days" +%s)
FILESJSON=$(curl -s https://slack.com/api/files.list?token=$TOKEN\&ts_to=$TSTO\&count=$COUNT\&types=$TYPES\&user=$USER)
ALLIDFILES=$(echo $FILESJSON | jq -r .files[].id)
NUMBEROFFILES=$(echo $ALLIDFILES | tr -s " " "\n" | wc -l)

echo "We are going to delete $NUMBEROFFILES files from owner $MEMBER_NAME older than $DAYS days, is this correct? y/n"
read CONFIRMATION

if [ "$CONFIRMATION" == "y" ]
then
        for FILEID in $ALLIDFILES
        do
                echo "Deleting $FILEID"
                curl -s https://slack.com/api/files.delete?token=$TOKEN\&file=$FILEID

        done
        echo "All files deleted"
        exit 0
elif [ "$CONFIRMATION" == "n" ]
then
        echo "Canceled."
        exit 0
else
        echo "Unknown option"
        exit 1
fi
