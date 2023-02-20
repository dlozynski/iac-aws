# NOTE: Don't modify this file directly - see Makefile

FROM alpine:3 as build-plugin
ARG PLUGIN_MODULE=github.com/traefik/plugindemo
ARG PLUGIN_GIT_REPO=https://github.com/traefik/plugindemo.git
ARG PLUGIN_GIT_BRANCH=master
RUN apk add --update git openssh-client

# Make ssh dir
# Create known_hosts
# Add bitbuckets key
RUN mkdir /root/.ssh/ \
 && touch /root/.ssh/known_hosts \
 && ssh-keyscan github.com >> /root/.ssh/known_hosts

RUN --mount=type=ssh \
      git clone ${PLUGIN_GIT_REPO} /plugins-local/src/${PLUGIN_MODULE} \
      --depth 1 --single-branch --branch ${PLUGIN_GIT_BRANCH}

FROM traefik:2.7

LABEL git.commithash="280084e"

COPY GeoLite2-City.mmdb /var/lib/geoip2/

COPY --from=build-plugin /plugins-local /plugins-local
