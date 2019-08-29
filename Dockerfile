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

# Dependencies needed to run chrome headless
# https://github.com/Googlechrome/puppeteer/issues/290#issuecomment-322921352
RUN apt-get update && \
  apt-get install -yq gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 \
  libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 \
  libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 \
  libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 \
  ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget

# Install docker
ENV VER "17.03.0-ce"
RUN curl -L -o /tmp/docker-$VER.tgz https://download.docker.com/linux/static/stable/x86_64/docker-$VER.tgz
RUN tar -xz -C /tmp -f /tmp/docker-$VER.tgz
RUN mv /tmp/docker/* /usr/bin
RUN docker --version

# Copy over application code
COPY package.json yarn.lock ./

# Install yarn
RUN npm install -g yarn@1.17.3
ENV PATH="$HOME/.local/bin:/root/.local/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Install npm
RUN yarn global add ts-node typescript check-dependencies
RUN yarn add puppeteer

# Install pre-commit, awscli
RUN pip install --upgrade pip
RUN pip install --user 'pyyaml==3.12' pre-commit pathlib2
RUN pip install --user --upgrade awscli && export PATH=$PATH:$HOME/.local/bin

# Expose envs TODO unecessary?
ENV CIRCLE_COMPARE_URL ${CIRCLE_COMPARE_URL}
ENV CIRCLE_BRANCH ${CIRCLE_BRANCH}
ENV CIRCLE_PROJECT_REPONAME ${CIRCLE_PROJECT_REPONAME}
ENV CI ${CI}
ENV AWS_ACCESS_KEY_ID ${AWS_ACCESS_KEY_ID}
ENV AWS_REGION ${AWS_REGION}
ENV AWS_SECRET_ACCESS_KEY ${AWS_SECRET_ACCESS_KEY}
ENV NPM_TOKEN ${NPM_TOKEN}
ENV NPM_EMAIL ${NPM_EMAIL}
