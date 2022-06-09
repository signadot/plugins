FROM ubuntu

# Install apt packages we need.
RUN apt-get update && \
    apt-get install -y ca-certificates curl zip jq && \
    apt-get clean autoclean && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

# Install AWS CLI.
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Add our plugin's scripts.
COPY provision deprovision /signadot/plugin/bin/
