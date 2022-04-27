#!/bin/bash
# Use this script in combination with individual permission files when you can't export the service account credentials into temporary tokens in GCP
# Might be some transcription errors in this...

COUNTER=0
TOTAL=`ls -lR *.json | wc -l`
VALID=0
PROJECT="GCP PROJECT NAME"

printf "[+] Checking service account against %d GCP Permissions\n" $TOTAL

for jfile in *.json; do

    RESPCURL=`curl -X POST -H "Authorization: Bearer "$(gcloud auth application-default print-access-token) -H "Content-Type: application/json; charset=utf-8" -d @$jfile "https://cloudresourcemanager.googleapis.com/v1/projects/$($PROJECT):testIamPermissions" -s | tr '\n' ' ' | python3 -mjson.tool`;

    (( COUNTER++ ))

    if [[ $RESPCURL != "{}" ]]; then
        if grep -q "error" <<< $RESPCURL; then
            continue
        fi
        
        printf "[!] Valid Permission: "
        echo $RESPCURL
        printf "\n"
        (( VALID++ ))
    fi
done

printf "[+] Checked [%d] permissions. Found [%d] valid permissions\n" $COUNTER $Valid