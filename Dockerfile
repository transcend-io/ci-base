# Node image
ARG NODE_IMAGE=10.15.0

# Image for building
FROM node:${NODE_IMAGE} AS npm_compiler

# Envs
ARG NPM_VERSION=6.4.1
ARG TS_NODE_VERSION=8.3.0
ARG DOCKER_COMPOSE_VERSION=1.21.2
ARG CI=true

# Install required packages available from the Debian repo
# NOTE: output isn't cleaned up so base images can easily run install again w/o
# needing to run `apt-get update`
RUN apt-get update && apt-get install -y \
    python \
    python-dev \
    python-pip \
    shellcheck \
    # postgresql-dev make g++ openssh bash curl \
    # tini libpq postgresql-client
    git

# Copy over application code
COPY package.json yarn.lock /base/

# Install npm
RUN npm i -g npm@${NPM_VERSION}
RUN npm i -g ts-node@${TS_NODE_VERSION}
RUN npm i -g check-dependencies

# Setup a simple init process & libpq
# ENTRYPOINT ["/sbin/tini", "--"]
# Use bash instead of sh
# SHELL ["/bin/bash", "-c"]

# Install yarn
RUN curl -o- -L https://yarnpkg.com/install.sh | bash

# Install pre-commit, docker-compose,awscli
ENV PATH="$HOME/.local/bin:/root/.local/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
RUN pip install --upgrade pip
RUN pip install --user 'pyyaml==3.12' pre-commit pathlib2 docker-compose==${DOCKER_COMPOSE_VERSION}
RUN pip install --user --upgrade awscli && export PATH=$PATH:$HOME/.local/bin

# Expose envs
ENV CIRCLE_COMPARE_URL ${CIRCLE_COMPARE_URL}
ENV CIRCLE_BRANCH ${CIRCLE_BRANCH}
ENV CIRCLE_PROJECT_REPONAME ${CIRCLE_PROJECT_REPONAME}
ENV CI ${CI}
ENV AWS_ACCESS_KEY_ID ${AWS_ACCESS_KEY_ID}
ENV AWS_REGION ${AWS_REGION}
ENV AWS_SECRET_ACCESS_KEY ${AWS_SECRET_ACCESS_KEY}
ENV NPM_TOKEN ${NPM_TOKEN}
ENV NPM_EMAIL ${NPM_EMAIL}
