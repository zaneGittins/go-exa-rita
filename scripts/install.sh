#!/usr/bin/env bash

INSTALL_DIR=/opt/go-exa-rita
CONFIG_DIR=/etc/upload-to-exabeam

if mkdir -p $INSTALL_DIR ; then
    /usr/bin/printf "\xE2\x9C\x94 created install directory.\n"
else
    /usr/bin/printf "\xE2\x9D\x8C Failed to create install directory.\n"
    exit
fi

if wget https://github.com/zaneGittins/exapi/releases/download/v0.0.1/upload-to-exabeam -O /bin/upload-to-exabeam ; then
    /usr/bin/printf "\xE2\x9C\x94 Downloaded upload-to-exabeam binary.\n"
    chmod +x $INSTALL_DIR/rita_ingest
else
    /usr/bin/printf "\xE2\x9D\x8C Failed to upload-to-exabeam binary.\n"
    exit
fi

if wget https://github.com/zaneGittins/exapi/releases/download/v0.0.1/config.ini -P $CONFIG_DIR/ ; then
    /usr/bin/printf "\xE2\x9C\x94 Downloaded sample config.ini.\n"
    chmod +x $INSTALL_DIR/rita_ingest
else
    /usr/bin/printf "\xE2\x9D\x8C Failed to download sample config.iniy.\n"
    exit
fi

if wget https://github.com/zaneGittins/go-exa-rita/releases/download/v0.0.1/run_rita_ingest.sh -P $INSTALL_DIR/ ; then
    /usr/bin/printf "\xE2\x9C\x94 Downloaded rita ingest script.\n"
    chmod +x $INSTALL_DIR/run_rita_ingest.sh
else
    /usr/bin/printf "\xE2\x9D\x8C Failed to download ingest script.\n"
    exit
fi

crontab_line="01 00 * * * $INSTALL_DIR/run_rita_ingest.sh"
if (crontab -u root -l; echo "$crontab_line" ) | crontab -u root - ; then
    /usr/bin/printf "\xE2\x9C\x94 Added rita_ingest.sh to crontab.\n"
else
    /usr/bin/printf "\xE2\x9D\x8C Failed to add crontab entry.\n"
    exit
fi