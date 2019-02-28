### STAGE 1: Build ###

FROM node:11.10-alpine as build

COPY ./package.json ./

RUN apk update && \
    apk add make python && \
    npm i && mkdir /ssh-app && mv ./node_modules ./ssh-app

WORKDIR /ssh-app

COPY . .

### STAGE 2: Setup ###

FROM alpine:3.9

COPY --from=build /ssh-app /usr/src/app

WORKDIR /usr/src/app

RUN apk update && \
    apk add nodejs nodejs-npm && \
    rm -rf /tmp/* /var/cache/apk/* /root/.npm /root/.node-gyp

# Connect to container with name/id
ENV CONTAINER=

# Shell to use inside the container
ENV CONTAINER_SHELL=bash

# Server key
ENV KEYPATH=./id_rsa

# Server port
ENV PORT=22

EXPOSE 22

CMD ["npm", "start"]
