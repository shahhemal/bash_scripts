#!/bin/bash

# Periodically executes curl command and captures response time in a log file

while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -t|--test-folder)
    TEST_FOLDER_ARG="$2"
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
esac
done

if [[ -z $TEST_FOLDER_ARG ]]; then
    echo "Missing TEST_FOLDER_ARG argument for eg: -t w1508272_u31291675_fast"
    exit 1
fi

if [[ -z $USER_ID_ARG ]]; then
    echo "Missing USER_ID argument for eg: -u 31291675"
    exit 1
fi

if [[ $REQUEST_JSON = *"workspace"* && -n $WS_ID_ARG ]]; then
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

source ${ENV}_common_config.sh
source $TEST_FOLDER_ARG/config.sh

if [[ -z $TEST_NAME ]]; then
    TEST_NAME=$TEST_FOLDER_ARG
    echo "TEST_NAME is empty, setting default to:" $TEST_NAME
fi

if [[ -z $MAX_REQUEST ]]; then
    MAX_REQUEST=10
    echo "MAX_REQUEST is empty, setting default to:" $MAX_REQUEST
fi

if [[ -z $MAX_INTERVAL ]]; then
    MAX_INTERVAL=10s
    echo "MAX_INTERVAL is empty, setting default to:" $MAX_INTERVAL
fi

# User id for whom search request is executed
USER_ID="$USER_ID_ARG"

# (OPTIONAL) Workspace id against which search request has to get executed
WORKSPACE_ID="$WS_ID_ARG"

# Name of file which contains unique search terms for the test
SEARCH_TERMS_FILE="$TEST_FOLDER_ARG/search_terms.txt"

echo TEST_NAME = $TEST_NAME
echo MAX_REQUEST  = $MAX_REQUEST
echo MAX_INTERVAL = $MAX_INTERVAL
echo SEARCH_URL = $SEARCH_URL
echo REQUEST_JSON = $REQUEST_JSON

echo USER_ID = $USER_ID
echo WORKSPACE_ID = $WORKSPACE_ID
echo SEARCH_TERMS_FILE = $SEARCH_TERMS_FILE


FILE_CONTENT=$(cat $REQUEST_JSON | jq -c .)
#echo "original file content: " $FILE_CONTENT

CNT=0

while [ $CNT -lt $MAX_REQUEST ]; do

    RANDOM_WORD=$(cat $SEARCH_TERMS_FILE | shuf -n 1)
    #echo $RANDOM_WORD

    FILE_CONTENT=$(echo "${FILE_CONTENT//user_id_param/$USER_ID}")
    FILE_CONTENT=$(echo "${FILE_CONTENT//workspace_id_param/$WORKSPACE_ID}")
    FILE_CONTENT=$(echo "${FILE_CONTENT//query_term_param/$RANDOM_WORD}")

    #echo "modified file content before curl request: " $FILE_CONTENT

    DATE=$(date +%d-%m-%Y" "%H:%M:%S);

    curl -u elastic:changeme -o /dev/null -s -w "$TEST_NAME - $DATE - $RANDOM_WORD - %{time_total}\n" -XPOST $SEARCH_URL -d "$FILE_CONTENT" >> $LOG_FILE
    #curl -u elastic:changeme -o "logs/output.txt" -XPOST $SEARCH_URL -d "$FILE_CONTENT"

    CNT=$[$CNT+1]

    if (("$CNT" < $MAX_REQUEST)); then
        sleep "$MAX_INTERVAL"
    fi
done

echo ""
echo "### Execution completed ###"
echo ""