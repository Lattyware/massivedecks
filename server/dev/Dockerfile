ARG NODE_VERSION=18

FROM node:${NODE_VERSION}-alpine

EXPOSE 8081

VOLUME [ "/md/server" ]
WORKDIR "/md/server"

ENV MD_CONFIG_PATH "config.json5"
ENV NODE_ENV "development"

ENTRYPOINT [ "npm" ]
CMD [ "run", "dev" ]
