# Example Baseline

This directory contains a minimalist example baseline deployment 
against which the resource plugins can be tested. 

It consists of a single Deployment which can echo environment variables.

To install in namespace `<namespace>`, apply the yaml in this directory:

```bash
kubectl -n <namespace> apply -f k8s
```
