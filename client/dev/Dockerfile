ARG NODE_VERSION=18

FROM node:${NODE_VERSION}-alpine

EXPOSE 8080

VOLUME [ "/md/client" ]
WORKDIR "/md/client"

ENV MD_DEV_ENV "docker"
ENV NODE_ENV "development"

ENTRYPOINT [ "npm" ]
CMD [ "run", "dev" ]
