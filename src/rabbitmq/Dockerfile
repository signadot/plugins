FROM rabbitmq:3.9-management

# Install apt packages we need.
RUN apt-get update && \
    apt-get install -y jq && \
    apt-get clean autoclean && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

COPY provision deprovision /signadot/provision/bin/

