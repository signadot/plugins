package k8sapplier

import (
	"bufio"
	"context"
	"fmt"
	"io"

	k8serrors "k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/api/meta"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/runtime/schema"
	serializeryaml "k8s.io/apimachinery/pkg/runtime/serializer/yaml"
	utilyaml "k8s.io/apimachinery/pkg/util/yaml"
	"k8s.io/client-go/dynamic"
)

var decUnstructured = serializeryaml.NewDecodingSerializer(unstructured.UnstructuredJSONScheme)

type K8SApplier struct {
	mapper meta.RESTMapper
	dyn    *dynamic.DynamicClient
	owner  *unstructured.Unstructured
}

func NewK8SApplier(mapper meta.RESTMapper, dyn *dynamic.DynamicClient,
	owner *unstructured.Unstructured) *K8SApplier {
	return &K8SApplier{
		mapper: mapper,
		dyn:    dyn,
		owner:  owner,
	}
}

func (a *K8SApplier) Apply(ctx context.Context, input io.Reader) error {
	// parse all k8s resources
	multidocReader := utilyaml.NewYAMLReader(bufio.NewReader(input))
	for {
		data, err := multidocReader.Read()
		if err != nil {
			if err == io.EOF {
				return nil
			}
			return fmt.Errorf("failed to read yaml data, %w", err)
		}

		// apply k8s resource
		err = a.applyObj(ctx, data)
		if err != nil {
			return err
		}
	}
}

func (a *K8SApplier) applyObj(ctx context.Context, data []byte) error {
	// decode the provided yaml
	gvk, obj, err := a.decodeObject(data)
	if err != nil {
		return fmt.Errorf("could not decode provided yaml, %w", err)
	}

	// get a resource interface
	dr, err := a.getResourceInterface(gvk, obj)
	if err != nil {
		return fmt.Errorf("could not get resource interface for object %s name=%s, %w",
			gvk, obj.GetName(), err)
	}

	// check if the object exist
	exists, err := a.objectExist(ctx, dr, obj)
	if err != nil {
		return fmt.Errorf("could not read object %s name=%s from cluster, %w",
			gvk, obj.GetName(), err)
	}
	if exists {
		return fmt.Errorf("the object %s name=%s already exist in the cluster",
			gvk, obj.GetName())
	}

	err = a.createObject(ctx, dr, obj)
	if err != nil {
		return fmt.Errorf("could not create object %s name=%s, %w",
			gvk, obj.GetName(), err)
	}
	return nil
}

func (a *K8SApplier) decodeObject(yamlContent []byte) (*schema.GroupVersionKind, *unstructured.Unstructured, error) {
	obj := &unstructured.Unstructured{}
	_, gvk, err := decUnstructured.Decode(yamlContent, nil, obj)
	if err != nil {
		return nil, nil, err
	}
	return gvk, obj, nil
}

func (a *K8SApplier) getResourceInterface(gvk *schema.GroupVersionKind,
	obj *unstructured.Unstructured) (dynamic.ResourceInterface, error) {
	// find the GVR
	mapping, err := a.mapper.RESTMapping(gvk.GroupKind(), gvk.Version)
	if err != nil {
		return nil, err
	}

	// get REST interface for the GVR
	var dr dynamic.ResourceInterface
	if mapping.Scope.Name() == meta.RESTScopeNameNamespace {
		// namespaced resources should specify the namespace
		dr = a.dyn.Resource(mapping.Resource).Namespace(obj.GetNamespace())
	} else {
		// for cluster-wide resources
		dr = a.dyn.Resource(mapping.Resource)
	}
	return dr, nil
}

func (a *K8SApplier) objectExist(ctx context.Context, dr dynamic.ResourceInterface,
	obj *unstructured.Unstructured) (bool, error) {
	clusterObj, err := dr.Get(ctx, obj.GetName(), metav1.GetOptions{})
	if err != nil {
		if k8serrors.IsNotFound(err) {
			return false, nil
		}
		return false, err
	}
	return clusterObj != nil, nil
}

func (a *K8SApplier) createObject(ctx context.Context, dr dynamic.ResourceInterface,
	obj *unstructured.Unstructured) error {
	// set owner references pointing to the resource
	obj.SetOwnerReferences([]metav1.OwnerReference{
		*metav1.NewControllerRef(a.owner, a.owner.GroupVersionKind()),
	})
	// create the object
	_, err := dr.Create(ctx, obj, metav1.CreateOptions{})
	return err
}
