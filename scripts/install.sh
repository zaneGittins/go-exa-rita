#!/usr/bin/env bash

INSTALL_DIR=/opt/go-exa-rita

if mkdir -p $INSTALL_DIR ;
    /usr/bin/printf "\xE2\x9C\x94 created install directory.\n"   
else
    /usr/bin/printf "\xE2\x9D\x8C Failed to create install directory.\n"
    exit
fi

if wget https://github.com/zaneGittins/go-exa-rita/releases/latest/rita_ingest $INSTALL_DIR/ ;
    /usr/bin/printf "\xE2\x9C\x94 Downloaded rita ingest binary.\n"
else 
    /usr/bin/printf "\xE2\x9D\x8C Failed to download ingest binary.\n"
    exit
fi

if wget https://github.com/zaneGittins/go-exa-rita/releases/latest/run_rita_ingest.sh $INSTALL_DIR/ ;
    /usr/bin/printf "\xE2\x9C\x94 Downloaded rita ingest script.\n" 
else
    /usr/bin/printf "\xE2\x9D\x8C Failed to download ingest script.\n"
    exit
fi

crontab_line="00 00 * * * $INSTALL_DIR/scripts/run_rita_ingest.sh"
if (crontab -u root -l; echo "$crontab_line" ) | crontab -u root - ; then
    /usr/bin/printf "\xE2\x9C\x94 Added rita_ingest.sh to crontab.\n"
else 
    /usr/bin/printf "\xE2\x9D\x8C Failed to add crontab entry.\n"
    exit
fi