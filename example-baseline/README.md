# Example Baseline

This directory contains a minimalist example baseline deployment against which
the resource plugins can be tested. 

It consists of a single Deployment which can echo environment variables.

To install this example in your cluster, run the following command (replacing
`<namespace>` with the corresponding value).

```bash
kubectl -n <namespace> apply -f k8s
```

The baseline serves an HTTP endpoint on port 8080 at `/` and output responses
giving the environment of the request.  For example:

```json
{
  "env": {
    "ECHO_ENV_PORT": "tcp://10.43.98.158:8080",
    "ECHO_ENV_PORT_8080_TCP": "tcp://10.43.98.158:8080",
    "ECHO_ENV_PORT_8080_TCP_ADDR": "10.43.98.158",
    "ECHO_ENV_PORT_8080_TCP_PORT": "8080",
    "ECHO_ENV_PORT_8080_TCP_PROTO": "tcp",
    "ECHO_ENV_SERVICE_HOST": "10.43.98.158",
    "ECHO_ENV_SERVICE_PORT": "8080",
    "ECHO_ENV_SERVICE_PORT_HTTP_WEB": "8080",
    "HOME": "/root",
    "HOSTNAME": "echo-env-6b687cfd8d-zngsk",
    "KUBERNETES_PORT": "tcp://10.43.0.1:443",
    "KUBERNETES_PORT_443_TCP": "tcp://10.43.0.1:443",
    "KUBERNETES_PORT_443_TCP_ADDR": "10.43.0.1",
    "KUBERNETES_PORT_443_TCP_PORT": "443",
    "KUBERNETES_PORT_443_TCP_PROTO": "tcp",
    "KUBERNETES_SERVICE_HOST": "10.43.0.1",
    "KUBERNETES_SERVICE_PORT": "443",
    "KUBERNETES_SERVICE_PORT_HTTPS": "443",
    "LANG": "C.UTF-8",
    "LC_ALL": "C.UTF-8",
    "PATH": "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  },
  "header": {
    "Accept": [
      "*/*"
    ],
    "User-Agent": [
      "curl/7.81.0"
    ]
  },
  "method": "GET",
  "requestURL": "/"
}

```
