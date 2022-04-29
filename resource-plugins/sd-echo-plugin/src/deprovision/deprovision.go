package main

import (
	"encoding/json"
	"flag"
	"log"
	"os"
	"time"

	"signadot.com/echo-plugin/datamount"
)

func main() {
	flag.Parse()
	if len(flag.Args()) != 2 {
		log.Fatal("usage: provision <sandbox-id> <resource-name>")
	}
	sandboxID := flag.Args()[0]
	resource := flag.Args()[1]
	log.Printf("deprovisioning resource %q for sandbox %s\n", resource, sandboxID)
	in, e := datamount.ReadDataMount(datamount.InputDir())
	if e != nil {
		log.Fatal(e)
	}
	out, e := datamount.ReadDataMount(datamount.OutputDir())
	if e != nil {
		log.Fatal(e)
	}
	type j struct {
		ProvisionInput  map[string][]byte
		ProvisionOutput map[string][]byte
	}
	if in["delay"] != nil {
		dur, err := time.ParseDuration(string(in["delay"]))
		if err != nil {
			log.Fatal(err)
		}
		log.Printf("Sleeping for %v ('delay' input param) to simulate long-running process...", dur)
		time.Sleep(dur)
	}
	if err := json.NewEncoder(os.Stdout).Encode(&j{ProvisionInput: in, ProvisionOutput: out}); err != nil {
		log.Fatal(err)
	}

}
