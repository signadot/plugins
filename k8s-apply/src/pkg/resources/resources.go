package resources

import (
	"context"
	"fmt"

	"k8s.io/apimachinery/pkg/api/meta"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/labels"
	"k8s.io/apimachinery/pkg/runtime/schema"
	"k8s.io/apimachinery/pkg/selection"
	"k8s.io/client-go/dynamic"
)

const (
	signadotGroup   = "signadot.com"
	signadotVersion = "v1"
	resourceKind    = "Resource"

	sandboxIDLabel    = "signadot.com/sandbox-id"
	resourceNameLabel = "signadot.com/resource-name"
)

func GetOwnerResource(ctx context.Context, mapper meta.RESTMapper, dyn *dynamic.DynamicClient,
	routingKey, resourceName string) (*unstructured.Unstructured, error) {
	// get a resource interface
	gk := schema.GroupKind{
		Group: signadotGroup,
		Kind:  resourceKind,
	}
	mapping, err := mapper.RESTMapping(gk, signadotVersion)
	if err != nil {
		return nil, fmt.Errorf("could not get rest mapper for Resources, %w", err)
	}
	dr := dyn.Resource(mapping.Resource)

	rkReq, _ := labels.NewRequirement(sandboxIDLabel, selection.Equals, []string{routingKey})
	resReq, _ := labels.NewRequirement(resourceNameLabel, selection.Equals, []string{resourceName})
	selector := labels.NewSelector()
	selector = selector.Add(*rkReq, *resReq)

	// find the corresponding Resource
	objList, err := dr.List(ctx, v1.ListOptions{
		LabelSelector: selector.String(),
	})
	if err != nil {
		return nil, fmt.Errorf("could not list Resources, %w", err)
	}
	if len(objList.Items) != 1 {
		return nil, fmt.Errorf("expected to find 1 Resource, but found %d", len(objList.Items))
	}
	return &objList.Items[0], nil
}
