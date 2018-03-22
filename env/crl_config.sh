#!/bin/bash

# config param file

# Total number of requests to be executed
MAX_REQUEST=100

# Max interval between 2 consecutive request eg: 2s (2 secs) or 5m (5 mins)
MAX_INTERVAL=15m

# Search url
SEARCH_URL=http://172.25.20.93:9200/il-search-ilp/_search

# Log file location
LOG_FILE="/var/log/kibana/response_time_monitoring_test.log"