#!/bin/bash

# config param file

# Total number of requests to be executed
MAX_REQUEST=2

# Max interval between 2 consecutive request eg: 2s (2 secs) or 5m (5 mins)
MAX_INTERVAL=5s

# Request json file path
REQUEST_JSON="../query_json/workspaceMetadataQuery.json"

# Test name to get printed in logs to differentiate different execution
TEST_NAME=""