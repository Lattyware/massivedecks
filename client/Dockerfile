FROM node:11-alpine

WORKDIR /md

COPY ["./package.json", "./package-lock.json", "./"]
RUN ["npm", "ci"]

COPY ["./tsconfig.json", "./webpack.config.js", "./elm.json", "./"]
COPY ["./src", "./src"]
COPY ["./assets", "./assets"]
RUN ["npm", "run", "build"]

FROM nginx:mainline-alpine
LABEL maintainer="team@rereadgames.com"

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

EXPOSE 8080

LABEL org.label-schema.name="massivedecks/client"
LABEL org.label-schema.description="The web client for Massive Decks, a comedy party game."
LABEL org.label-schema.url="https://github.com/Lattyware/massivedecks"
LABEL org.label-schema.vcs-url="https://github.com/Lattyware/massivedecks"
LABEL org.label-schema.vendor="Reread Games"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.version=$VERSION

COPY --from=0 ["/md/dist", "/usr/share/nginx/html/"]
COPY ["./nginx.conf", "/etc/nginx/nginx.conf"]
