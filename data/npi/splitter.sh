#!/bin/bash

#SPLIT=/usr/bin/split
SPLIT=/usr/local/bin/gsplit
FILENAME=`ls npi*.csv`

tail -n +2 ${FILENAME} | ${SPLIT} --bytes=500MB -d --filter='sh -c "{ head -n 1 ${FILENAME}; cat; } > $FILE"' --additional-suffix=.csv - npi-split-
