FROM node:11-alpine

WORKDIR /md

COPY ["./src", "./src"]
COPY ["./package.json", "./package-lock.json", "./tsconfig.json", "./config.json5", "./"]
RUN ["npm", "ci"]
RUN ["npm", "run", "build"]

FROM node:11-alpine
LABEL maintainer="team@rereadgames.com"

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=dev

ENV MD_VERSION $VERSION

LABEL org.label-schema.name="massivedecks/server"
LABEL org.label-schema.description="The web server for Massive Decks, a comedy party game."
LABEL org.label-schema.url="https://github.com/Lattyware/massivedecks"
LABEL org.label-schema.vcs-url="https://github.com/Lattyware/massivedecks"
LABEL org.label-schema.vendor="Reread Games"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.version=$VERSION

WORKDIR /md

COPY --from=0 ["/md/dist", "./"]
COPY ["./package.json", "./package-lock.json", "./config.json5", "./"]
RUN ["npm", "ci", "--only=production"]

EXPOSE 8081
CMD ["node", "./index.js"]
