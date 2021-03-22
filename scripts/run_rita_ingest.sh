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

# RITA show beacons
if rita show-beacons $DB | tail -n +2 | head -10 | cut -d "," -f 3 | /bin/upload-to-exabeam -config="/etc/upload-to-exabeam/config.ini" -table="rita_beacons"; then
    /usr/bin/printf "\xE2\x9C\x94 RITA show-beacons uploaded to Exabeam.\n"
else
    /usr/bin/printf "\xE2\x9D\x8C Failed to analyze beacons.\n"
    exit
fi