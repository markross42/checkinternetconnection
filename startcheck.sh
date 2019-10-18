#!/bin/bash
#script for starting file from crontab, if script is running, do nothing
# for example, run startcheck.sh all 5 minutes
# */5 * * * * /path/to/startcheck.sh
FILE_NAME=checkinternetconnection.sh
cd $(dirname $0)
PGREP_RESULT=$(/usr/bin/pgrep $FILE_NAME)
RESULT_CODE=$?
if [ $RESULT_CODE -ge 1 ]
then
  #start FILE_NAME in background
  nohup ./$FILE_NAME &
fi
