#!/bin/bash

# config param file

# Total number of requests to be executed
MAX_REQUEST=2

# Max interval between 2 consecutive request eg: 2s (2 secs) or 5m (5 mins)
MAX_INTERVAL=5s

# Search url
SEARCH_URL=http://10.34.193.70:9200/il-search-ilp/_search

# Log file location
LOG_FILE="/var/log/kibana/response_time_monitoring_test.log"