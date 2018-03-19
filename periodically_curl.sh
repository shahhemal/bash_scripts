#!/bin/bash

# Periodically executes curl command and captures response time in a log file

LOG_FILE=response_output_$(date +"%Y%m%d%H%M").txt
echo Logs captured in $(pwd)/$LOG_FILE

CNT=0
MAX_REQ=5
MAX_INTERVAL=10

#while true; do
while [ $CNT -lt $MAX_REQ ]; do
    curl -u elastic:changeme -o /dev/null -s -w "Time: $(date)  Total time: %{time_total}\n" localhost:9200 >> $LOG_FILE

    CNT=$[$CNT+1]
    #echo $CNT

    if (("$CNT" < $MAX_REQ)); then
        sleep "$MAX_INTERVAL"s
    fi

done
