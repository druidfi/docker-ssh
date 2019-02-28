FROM node:9-onbuild as build

CMD ["npm", "start"]

FROM alpine:3.9
COPY --from=build /usr/src/app /usr/src/app

RUN apk update \
  && apk add nodejs nodejs-npm \
  && rm -rf /tmp/* /var/cache/apk/* /root/.npm /root/.node-gyp

# Connect to container with name/id
ENV CONTAINER=

# Shell to use inside the container
ENV CONTAINER_SHELL=bash

# Server key
ENV KEYPATH=./id_rsa

# Server port
ENV PORT=22

EXPOSE 22

WORKDIR /usr/src/app
CMD ["npm", "start"]
