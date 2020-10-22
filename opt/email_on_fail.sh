#! /bin/bash

set -eu

cmd=$1
description=$2

# run and get the exit status code
set +e
bash -c "$cmd"
status=$?
set -e

while [ $status -ne 0 ]; do
        echo "command $cmd failed"
        # echo the description of the issue
        echo "$description"
        echo "sending email"
        # get the name of this device
        hostname=$(hostname)
        set +e
        # chuck all details in an email and send
        printf "$cmd failed on ${hostname}\n\n$description" | mail -# -s "[${hostname}] $description" goastler4@gmail.com
        status=$?
        set -e
        # if the email failed to send then try again after delay
        echo "email send status: $status"
        if [ $status -ne 0 ]; then
                sleep 5m
        fi
done

