# Node image
ARG NODE_IMAGE=10.15.0-alpine

# Image for building
FROM node:${NODE_IMAGE} AS npm_compiler

# Versions
ARG NPM_VERSION=6.4.1
ARG TS_NODE_VERSION=8.3.0
ARG DOCKER_COMPOSE_VERSION=1.21.2
ARG CI=true

# Install packages
RUN mkdir -p /base
WORKDIR /base

# Copy over application code
COPY package.json yarn.lock /base/

# Install npm
RUN npm i -g npm@${NPM_VERSION}
RUN npm i -g ts-node@${TS_NODE_VERSION}

# Install python and pip
RUN apk add --no-cache \
    python3 \
    python2 \
    postgresql-dev make g++ \
    git openssh \
    bash curl

# Setup a simple init process & libpq
RUN apk add --no-cache tini libpq
RUN apk add --no-cache postgresql-client
ENTRYPOINT ["/sbin/tini", "--"]

# Install yarn
RUN touch ~/.bash_profile
ENV PATH="$HOME/.local/bin:/root/.local/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
RUN curl -o- -L https://yarnpkg.com/install.sh | bash
RUN source ~/.bash_profile

# Install pre-commit, docker-compose,awscli
RUN pip3 install --upgrade pip
RUN pip3 install --user 'pyyaml==3.12' pre-commit pathlib2 docker-compose==${DOCKER_COMPOSE_VERSION}
RUN pip3 install --user --upgrade awscli && export PATH=$PATH:$HOME/.local/bin

# Use bash instead of sh
SHELL ["/bin/bash", "-c"]

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
