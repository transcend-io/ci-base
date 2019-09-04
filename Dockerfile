# Node image
ARG NODE_IMAGE=10.15.0

# Image for building
FROM node:${NODE_IMAGE}

# Envs
ARG CI=true

# Install required packages available from the Debian repo
# NOTE: output isn't cleaned up so base images can easily run install again w/o
# needing to run `apt-get update`
# REFERENCE: https://github.com/luminopia/docker-ci-base-standard/blob/master/Dockerfile
# TODO python 3!! Jan 1 2020
RUN apt-get update && apt-get install -y \
    python \
    python-dev \
    python-pip \
    shellcheck \
    git \
    apt-transport-https \
    ca-certificates \
    gnupg2 \
    software-properties-common

# Copy over application code
COPY package.json yarn.lock ./

# Install yarn
RUN npm install -g yarn@1.17.3
ENV PATH="$HOME/.local/bin:/root/.local/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Install npm
RUN yarn global add ts-node typescript check-dependencies

# Install pre-commit, awscli
RUN pip install --upgrade pip
RUN pip install --user 'pyyaml==3.12' pre-commit pathlib2
RUN pip install --user --upgrade awscli && export PATH=$PATH:$HOME/.local/bin
