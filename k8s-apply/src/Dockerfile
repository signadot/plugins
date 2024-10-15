FROM golang:1.23 as builder

WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . ./
RUN go build ./cmd/k8s_apply


FROM ubuntu

# Install ca-certificates
RUN apt-get update && \
    apt-get install -y ca-certificates && \
    apt-get clean autoclean && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

WORKDIR /
COPY --from=builder /app/k8s_apply /usr/local/bin/k8s_apply
