package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"time"

	"github.com/signadot/plugins/k8s-apply/src/pkg/k8sapplier"
	"github.com/signadot/plugins/k8s-apply/src/pkg/resources"
	"k8s.io/client-go/discovery"
	"k8s.io/client-go/discovery/cached/memory"
	"k8s.io/client-go/dynamic"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/restmapper"
)

func main() {
	inputPath := flag.String("file", "", "input file")
	timeout := flag.Duration("timeout", time.Minute, "timeout value for the operation")
	flag.Parse()

	// read the input file
	if *inputPath == "" {
		panic("input file not defined")
	}
	file, err := os.Open(*inputPath)
	if err != nil {
		panic(fmt.Sprintf("could not open input file, %v", err))
	}

	// creates an in-cluster config
	cfg, err := rest.InClusterConfig()
	if err != nil {
		panic(err.Error())
	}

	// prepare a RESTMapper to find GVR
	dc, err := discovery.NewDiscoveryClientForConfig(cfg)
	if err != nil {
		panic(err.Error())
	}
	mapper := restmapper.NewDeferredDiscoveryRESTMapper(memory.NewMemCacheClient(dc))

	// prepare the dynamic client
	dyn, err := dynamic.NewForConfig(cfg)
	if err != nil {
		panic(err.Error())
	}

	ctx, cancel := context.WithTimeout(context.Background(), *timeout)
	defer cancel()

	// get required env vars
	routinKey := os.Getenv("SIGNADOT_SANDBOX_ROUTING_KEY")
	if routinKey == "" {
		panic("empty routing key")
	}
	resourceName := os.Getenv("SIGNADOT_RESOURCE_NAME")
	if resourceName == "" {
		panic("empty resource name")
	}

	// resolve the owner resource
	owner, err := resources.GetOwnerResource(ctx, mapper, dyn, routinKey, resourceName)
	if err != nil {
		panic(err.Error())
	}

	// apply the desired resources
	applier := k8sapplier.NewK8SApplier(mapper, dyn, owner)
	err = applier.Apply(ctx, file)
	if err != nil {
		panic(err.Error())
	}
}
