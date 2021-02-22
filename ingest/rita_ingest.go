package main

import (
	"encoding/csv"
	"flag"
	"io"
	"log"
	"os"
	"strconv"

	"github.com/zaneGittins/go-exa-rita/expi"
	"gopkg.in/ini.v1"
)

var (
	apiSection string = "api"

	// APIUsername - Username to authenticate to API.
	APIUsername string = ""

	// APIPassword - Password to authenticate to API.
	APIPassword string = ""

	// ContextTable - Context table to update.
	ContextTable string = ""

	// AAHost - Host to connect to.
	AAHost string = ""

	// ScoreThreshold - Beacon score must be equal to or above this threshold to be added to the context table.
	ScoreThreshold float64 = 0.9
)

// RITABeacon - Score,Source IP,Destination IP,Connections,Avg Bytes,Intvl Range,Size Range,Top Intvl,Top Size,Top Intvl Count,Top Size
type RITABeacon struct {
	Score         float64
	SourceIP      string
	DestinationIP string
	Connections   int
	AvgBytes      int
}

// UploadResults - Uploads a slice of RITABeacon to an Exabeam context table.
func UploadResults(beacons []RITABeacon) {

	// Initialize authentication struct and api struct.
	auth := expi.ExabeamAuth{Username: APIUsername, Password: APIPassword}
	api := expi.ExabeamAAApi{Auth: auth, Tablename: ContextTable, Host: AAHost}
	api.Initialize()

	// Authenticate to the API.
	result := api.Authenticate()
	if result != 200 {
		log.Printf("auth status code %d\n", result)
		return
	}

	// Create struct of keys to upload to context table.
	keys := []expi.NewKey{}
	for _, beacon := range beacons {
		newKey := expi.NewKey{Key: beacon.DestinationIP}
		keys = append(keys, newKey)
	}
	newRecords := expi.NewRecords{ContextTableName: api.Tablename, Records: keys}

	// Upload new records to the context table.
	result, resultJSON := api.AddRecords(newRecords)
	if result != 200 {
		log.Printf("add status code %d\n", result)
		return
	}

	// Commit changes to the context table.
	commit := expi.CommitChangesData{SessionId: resultJSON.SessionId, Replace: true}
	result = api.CommitChanges(commit)
	if result != 200 {
		log.Printf("commit status code %d\n", result)
		return
	}
}

func parseConfig(configFile string) {

	// Load and parse configuration file.
	cfg, err := ini.Load(configFile)
	if err != nil {
		log.Fatalln(err)
		return
	}

	// Get username for API from config.
	APIUsername = cfg.Section(apiSection).Key("username").String()

	// Get password for API from config.
	APIPassword = cfg.Section(apiSection).Key("password").String()

	// Get context table name from config.
	ContextTable = cfg.Section(apiSection).Key("context_table").String()

	// Get AA host name from config.
	AAHost = cfg.Section(apiSection).Key("host").String()

	// Get RITA beacon score threshold from config.
	ScoreThreshold, err = cfg.Section(apiSection).Key("score_threshold").Float64()
	if err != nil {
		log.Printf("Failed to read score_threshold with error %s\n", err)
	}
}

func main() {

	// Parse command line args.
	configPath := flag.String("config", "config.ini", "path to config file.")
	beaconPath := flag.String("beacon", "", "path to rita-beacons csv file.")
	flag.Parse()

	// Parse INI config file.
	parseConfig(*configPath)

	// Open beacon csv file.
	beaconCSV, err := os.Open(*beaconPath)
	if err != nil {
		log.Fatalf("Couldn't open %s due to %s\n", *beaconPath, err)
	}
	r := csv.NewReader(beaconCSV)

	// Slice to store all beacons above a given threshold.
	beacons := []RITABeacon{}

	// Iterate through each record in csv.
	for {

		// Break if last record.
		record, err := r.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Fatal(err)
		}

		// Get values from record.
		score, _ := strconv.ParseFloat(record[0], 32)
		connections, _ := strconv.Atoi(record[3])
		avgBytes, _ := strconv.Atoi(record[4])

		// Create new RITA beacon struct
		RITABeacon := RITABeacon{
			Score:         score,
			SourceIP:      record[1],
			DestinationIP: record[2],
			Connections:   connections,
			AvgBytes:      avgBytes,
		}
		if RITABeacon.Score >= ScoreThreshold {
			beacons = append(beacons, RITABeacon)
		}
	}

	// Upload slice to a context table using the exapi package.
	UploadResults(beacons)
}
