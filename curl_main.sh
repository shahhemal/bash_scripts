#!/bin/bash
#set -x

# Periodically executes curl command and captures response time in a log file

while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -t|--test-type)
    TEST_TYPE_ARG="$2"
    shift # past argument
    shift # past value
    ;;
    -u|--userid)
    USER_ID_ARG="$2"
    shift # past argument
    shift # past value
    ;;
    -w|--workspaceid)
    WS_ID_ARG="$2"
    shift # past argument
    shift # past value
    ;;
    -e|--env)
    ENV="$2"
    shift # past argument
    shift # past value
    ;;
    -m|--log-msg)
    LOG_MSG="$2"
    shift # past argument
    shift # past value
    ;;
esac
done

if [[ -z $TEST_TYPE_ARG ]]; then
    # options: ws_meta, ws_content, hub_meta, hub_content
    echo "Missing TEST_TYPE_ARG argument for eg: -t ws_meta"
    exit 1
fi

if [[ -z $USER_ID_ARG ]]; then
    echo "Missing USER_ID argument for eg: -u 31291675"
    exit 1
fi

# Request json file path
REQUEST_JSON="commons/$TEST_TYPE_ARG.json"

if [[ $REQUEST_JSON = *"ws"* && -z "$WS_ID_ARG" ]]; then
    echo "Missing WORKSPACE_ID argument for eg: -w 1508272"
    exit 1
fi

if [[ -z $ENV ]]; then
    echo "Missing ENV argument for eg: -e crl"
    exit 1
fi

echo ""
echo "### Execution started ###"
echo ""

source env/${ENV}_config.sh

if [[ -z $MAX_REQUEST ]]; then
    MAX_REQUEST=5
    echo "MAX_REQUEST is empty, setting default to:" $MAX_REQUEST
fi

if [[ -z $MAX_INTERVAL ]]; then
    MAX_INTERVAL=10s
    echo "MAX_INTERVAL is empty, setting default to:" $MAX_INTERVAL
fi

# Name of file which contains unique search terms for the test
SEARCH_TERMS_FILE="env/${ENV}_search_terms.txt"

echo TEST_TYPE = $TEST_TYPE_ARG
echo MAX_REQUEST  = $MAX_REQUEST
echo MAX_INTERVAL = $MAX_INTERVAL
echo SEARCH_URL = $SEARCH_URL
echo REQUEST_JSON = $REQUEST_JSON

echo USER_ID = $USER_ID_ARG
echo WORKSPACE_ID = $WS_ID_ARG
echo SEARCH_TERMS_FILE = $SEARCH_TERMS_FILE


FILE_CONTENT=$(cat $REQUEST_JSON | jq -c .)
#echo "original file content: " $FILE_CONTENT

# User id for whom search request is executed
USER_ID="$USER_ID_ARG"

# (OPTIONAL) Workspace id against which search request has to get executed
WORKSPACE_ID="$WS_ID_ARG"

COMM_LOG_MSG="testType: $TEST_TYPE_ARG - userId: $USER_ID_ARG - wsId: $WS_ID_ARG"

CNT=0

while [ $CNT -lt $MAX_REQUEST ]; do

    RANDOM_WORD=$(cat $SEARCH_TERMS_FILE | shuf -n 1)
    #echo $RANDOM_WORD

    FILE_CONTENT=$(echo "${FILE_CONTENT//user_id_param/$USER_ID}")
    FILE_CONTENT=$(echo "${FILE_CONTENT//workspace_id_param/$WORKSPACE_ID}")
    FILE_CONTENT=$(echo "${FILE_CONTENT//query_term_param/$RANDOM_WORD}")

    #echo "modified file content before curl request: " $FILE_CONTENT

    DATE=$(date +%d-%m-%Y" "%H:%M:%S);

    curl -u elastic:changeme -o /dev/null -s -w "$DATE - $LOG_MSG - $COMM_LOG_MSG - respTime: %{time_total} - searchTerm: $RANDOM_WORD\n" -XPOST $SEARCH_URL -d "$FILE_CONTENT" >> $LOG_FILE
    #curl -u elastic:changeme -o "logs/output.txt" -XPOST $SEARCH_URL -d "$FILE_CONTENT"

    CNT=$[$CNT+1]

    if (("$CNT" < $MAX_REQUEST)); then
        sleep "$MAX_INTERVAL"
    fi
done

echo ""
echo "### Execution completed ###"
echo ""