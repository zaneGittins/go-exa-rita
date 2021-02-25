# go-exa-rita

This is a project to integrate RITA, Sysmon, and Exabeam by uploading results from the `rita-beacons` command to an Exabeam Advanced Analytics context table.

RITA outputs results in CSV format, this integration reads that CSV and replaces the content of a context table with the results. That context table can the be used in Advanced Analytics rules to correlate RITA beacons and Sysmon network connection events (event ID 3).

## Installation

Prerequisites

* [Zeek](https://zeek.org/) installed.
* [RITA](https://github.com/activecm/rita) installed.
* [Exabeam Advanced Analytics](https://www.exabeam.com/product/exabeam-advanced-analytics/) configured and ingesting Sysmon network events.
    * An Exabeam AA user with the "manage context tables" permission.
    * A new key only context table, for example `rita-beacons`.

To run the automatic installer run the following commands:

```bash
wget https://github.com/zaneGittins/go-exa-rita/releases/download/v0.0.1/install.sh
chmod +x install.sh
./install.sh
```