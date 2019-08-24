# Node image
ARG NODE_IMAGE=10.15.0-alpine

# Image for building
FROM node:${NODE_IMAGE} AS npm_compiler

# Versions
ARG NPM_VERSION=6.4.1
ARG TS_NODE_VERSION=8.3.0
ARG DOCKER_COMPOSE_VERSION=1.21.2

# Install packages
RUN mkdir -p /base
WORKDIR /base

# Copy over application code
COPY package.json package-lock.json /base/

# Install npm
RUN npm i -g npm@${NPM_VERSION}
RUN npm i ts-node@${TS_NODE_VERSION}

# Install python and pip
RUN apk add --no-cache \
    python3

# Install pre-commit, docker-compose,awscli
ENV PATH="$HOME/.local/bin:/root/.local/bin:${PATH}"
RUN pip3 install --upgrade pip
# RUN pip install --upgrade pip
RUN pip3 install --user 'pyyaml==3.12' pre-commit pathlib2 docker-compose==${DOCKER_COMPOSE_VERSION}
RUN pip3 install --user --upgrade awscli && export PATH=$PATH:$HOME/.local/bin
