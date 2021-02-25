#!/usr/bin/env bash

# Directories
ZEEK_LOGS=/opt/zeek/logs
EXA_RITA_DIR=/opt/go-exa-rita

# Get yesterdays date.
TODAY=$(date --date='-1 day' +\%Y-\%m-\%d)
OUTPUT_BEACONS=beacon-$(hostname)-$TODAY.csv

# RITA database
DB=netmon-$TODAY

# RITA import Zeek data into netmon dataset.
if rita import $ZEEK_LOGS/$TODAY/ $DB ; then
    /usr/bin/printf "\xE2\x9C\x94 RITA ingest Zeek data.\n"
else
    /usr/bin/printf "\xE2\x9D\x8C Failed to ingest Zeek data.\n"
    exit
fi

 mkdir -p $EXA_RITA_DIR/rita-logs/

# RITA show beacons
if rita show-beacons $DB > $EXA_RITA_DIR/rita-logs/$OUTPUT_BEACONS ; then
    sed -i '1d' $EXA_RITA_DIR/rita-logs/$OUTPUT_BEACONS
    /usr/bin/printf "\xE2\x9C\x94 RITA show-beacons.\n"
else
    /usr/bin/printf "\xE2\x9D\x8C Failed to analyze beacons.\n"
    exit
fi

# Ingest into rita_ingest
if $EXA_RITA_DIR/rita_ingest -config="$EXA_RITA_DIR/config.ini" -beacon="$EXA_RITA_DIR/rita-logs/$OUTPUT_BEACONS" ; then
    /usr/bin/printf "\xE2\x9C\x94 Ingested rita beacons and posted to context table.\n"
else
    /usr/bin/printf "\xE2\x9D\x8C Failed to post to context table API.\n"
    exit
fi