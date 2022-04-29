package main

import (
	"flag"
	"log"
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
	log.Printf("provisioning resource %q for sandbox %s\n", resource, sandboxID)
	d, e := datamount.ReadDataMount(datamount.InputDir())
	if e != nil {
		log.Fatal(e)
	}

	if d["delay"] != nil {
		dur, err := time.ParseDuration(string(d["delay"]))
		if err != nil {
			log.Fatal(err)
		}
		log.Printf("Sleeping for %v ('delay' input param) to simulate long-running process...", dur)
		time.Sleep(dur)
	}

	if err := datamount.WriteDataMount(datamount.OutputDir(), d); err != nil {
		log.Fatal(err)
	}

}
