#!/bin/bash
#
# check internet connection by ping host and use resultcode and roundtrip time to descide, if the connection is up
#

HOST_TO_PING=8.8.8.8 # 8.8.8.8 / 4.4.4.4 google DNS
LOG_FILE=checkinternetconnection.log

# if logfile does no exist, create it and write header
# dd.mm.yyyy;hh:mm:ss;fail state;roundtrip time;fail name;result code
# dd.mm.yyyy: date
# hh:mm:ss: time
# fail state: Start failure, End failure, Failure exists, End failure
# roundtrip time: ping time time (in milliseconds)
# fail name: PING_OK, PING_FAILED, TOO_QUICKLY

if [ ! -f "$LOG_FILE" ]; then
    echo "dd.mm.yyyy;hh:mm:ss;Fail state;roundtrip time;fail name;result code" >> $LOG_FILE
fi
BC_CMD='/usr/bin/bc -l'
#minimum ping time - my isp responds every ping. Even if the network is not
# reachable by the broadband router. So ping times less than 10ms are internal -> FAIL
MIN_TIME=10.0
#how long should be waited between pings (in seconds)
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
  # the ping was not successfull
  if [ $RESULT_CODE -ge 1 ] && [ $FAILURE -eq 0 ]
    then
    FAILURE=1
    echo "$DATETIME;Start failure;$TIME;PING_FAILED;$RESULT_CODE"
    echo "$DATETIME;Start failure;$TIME;PING_FAILED;$RESULT_CODE" >> $LOG_FILE
  fi
  # the ping was successfull
  if [ $RESULT_CODE -eq 0 ] && [ $FAILURE -eq 0 ]
  then
    PING_TOO_QUICKLY=$(echo "$TIME < $MIN_TIME" | bc -l) # when ping time is < than minimal time, the ping seems to be from local network
    if [ $PING_TOO_QUICKLY -eq 1 ] # was the ping in the internal or external network?
    then
      FAILURE=1
      echo "$DATETIME;Start failure;$TIME;TOO_QUICKLY;$RESULT_CODE"
      echo "$DATETIME;Start failure;$TIME;TOO_QUICKLY;$RESULT_CODE" >> $LOG_FILE
    else
      FAILURE=0
      #echo "$DATETIME;Ping ok;$TIME;OK"
    fi
  fi
 # the ping was successfull, check if the ping was replied internal (-> failure still exists) or external (-> end failure)
  if [ $RESULT_CODE -eq 0 ] && [ $FAILURE -eq 1 ]
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