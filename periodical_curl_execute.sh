#!/bin/bash

# Periodically executes curl command and captures response time in a log file
# curl -u elastic:changeme -XPOST http://localhost:9200/il-search-ilp/_search -d @/home/kbolineni/hubSearchQuery.json


LOG_FILE="/var/log/kibana/response_time_monitoring_test.log"

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -r|--requests)
    MAX_REQUEST="$2"
    shift # past argument
    shift # past value
    ;;
    -i|--interval)
    MAX_INTERVAL="$2"
    shift # past argument
    shift # past value
    ;;
esac
done


if [[ -z $MAX_REQUEST ]]; then
    MAX_REQUEST=10
    echo "MAX_REQUEST is empty, setting default to:" $MAX_REQUEST
fi

if [[ -z $MAX_INTERVAL ]]; then
    MAX_INTERVAL=10s
    echo "MAX_INTERVAL is empty, setting default to:" $MAX_INTERVAL
fi


echo MAX_REQUEST  = $MAX_REQUEST
echo MAX_INTERVAL = $MAX_INTERVAL

CNT=0

while [ $CNT -lt $MAX_REQUEST ]; do
    curl -u elastic:changeme -o /dev/null -s -w "Time: $(date)  Total time: %{time_total}\n" -XPOST http://10.34.193.70:9200/il-search-ilp/_search -d @workspaceMetadataQuery_New.json >> $LOG_FILE

    CNT=$[$CNT+1]

    if (("$CNT" < $MAX_REQUEST)); then
        sleep "$MAX_INTERVAL"
    fi
done