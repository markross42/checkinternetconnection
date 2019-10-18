#!/bin/bash
#
# check internet connection by ping host and use resultcode and roundtrip time to descide, if the connection is up
#

HOST_TO_PING=8.8.8.8 # 8.8.8.8 / 4.4.4.4 google DNS
LOG_FILE=checkinternetconnection.log
BC_CMD='/usr/bin/bc -l'
#minimum ping time - my isp responds every ping. Even if the network is not
# reachable by the broadband router. So ping times less than 10ms are internal -> FAIL
MIN_TIME=10.0
#how long - in seconds - should be waited between pings
WAITING=5

#init fault indicator (ping failed -> 1; ping ok  -> 0)
FAILURE=0

while true
do
  DATETIME=$(date +%Y.%m.%d\;%H:%M:%S)
  #ping
  PING_RESULT=$(ping -qc1 $HOST_TO_PING)
  RESULT_CODE=$?
  #grab only time from ping
  TIME=$(echo -e "$PING_RESULT"  | tail -n1 | awk '{print $4}' | cut -f 2 -d "/")
  if [ $RESULT_CODE -ge 1 ] && [ $FAILURE -eq 0 ] # the ping was not successfull
    then
    FAILURE=1
    echo "$DATETIME;Start failure;$TIME;PING_FAILED;$RESULT_CODE"
    echo "$DATETIME;Start failure;$TIME;PING_FAILED;$RESULT_CODE" >> $LOG_FILE
  fi
  
  if [ $RESULT_CODE -eq 0 ] && [ $FAILURE -eq 0 ] # the ping was successfull
  then
    PING_TOO_QUICKLY=$(echo "$TIME < $MIN_TIME" | bc -l) # when ping time is < than  minimal time, the ping seems to be from local network
    if [ $PING_TOO_QUICKLY -eq 1 ] # was the ping in the internal or external network?
    then
      FAILURE=1
      echo "$DATETIME;Start failure;$TIME;TOO_QUICKLY;$RESULT_CODE"
      echo "$DATETIME;Start failure;$TIME;TOO_QUICKLY;$RESULT_CODE" >> $LOG_FILE
    else
      FAILURE=0
      echo "$DATETIME;Ping ok;$TIME;OK"
    fi
  fi

  if [ $RESULT_CODE -eq 0 ] && [ $FAILURE -eq 1 ] # the ping was successfull, failure exits
  then
    if (( $(echo "$TIME < $MIN_TIME" |bc -l) )) # was the ping in the internal or external network
    then
      #FAILURE=1
      echo "$DATETIME;Failure exists;$TIME;TOO_QUICKLY;$RESULT_CODE"
      #echo $DATETIME ";Start failure;$TIME;TOO_QUICKLY" >> $LOG_FILE
    else
      FAILURE=0
    echo "$DATETIME;End failure;$TIME;PING_OK;$RESULT_CODE"
    echo "$DATETIME;End failure;$TIME;PING_OK;$RESULT_CODE" >> $LOG_FILE
    fi
  fi
  sleep $WAITING
done