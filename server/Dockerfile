FROM --platform=linux/amd64 node:16-alpine AS build

WORKDIR /md

COPY ["./package.json", "./package-lock.json", "./"]
RUN ["npm", "ci"]

COPY ["./src", "./src"]
COPY ["./tsconfig.json", "./config.json5", "./"]
RUN ["npm", "run", "build"]

FROM node:16-alpine

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=$VCS_REF-dev

ENV MD_VERSION $VERSION

LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.url="https://github.com/Lattyware/massivedecks"
LABEL org.opencontainers.image.source="https://github.com/Lattyware/massivedecks"
LABEL org.opencontainers.image.version=$VERSION
LABEL org.opencontainers.image.revision=$VCS_REF
LABEL org.opencontainers.image.vendor="Reread Games <team@rereadgames.com>"
LABEL org.opencontainers.image.licenses="AGPL-3.0+"
LABEL org.opencontainers.image.title="Massive Decks (Server)"
LABEL org.opencontainers.image.description="The web server for Massive Decks, a comedy party game."

WORKDIR /md

COPY ["./package.json", "./package-lock.json", "./"]
RUN ["npm", "ci", "--only=production"]

COPY ["./config.json5", "./"]
COPY ["./decks", "./decks"]
COPY --from=build ["/md/dist", "./"]

EXPOSE 8081
USER node
CMD ["node", "--es-module-specifier-resolution=node", "./index.js"]
