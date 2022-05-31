ARG NODE_VERSION=18
ARG MODE=production
ARG BUILD_DATE=unknown
ARG VCS_REF=unknown
ARG VERSION=${VCS_REF}-dev


FROM --platform=$BUILDPLATFORM node:${NODE_VERSION}-alpine AS build

ARG VERSION
ARG MODE

WORKDIR /md

RUN ["apk", "add", "--no-cache", "python3", "make", "g++"]

ENV MD_VERSION ${VERSION}
ENV WEBPACK_MODE ${MODE}

COPY ["./elm-material/package.json", "./elm-material/package-lock.json", "./"]
COPY ["./package.json", "./package-lock.json", "./"]
RUN ["npm", "ci"]

COPY ["./elm-material", "./elm-material"]
COPY ["./tsconfig.json", "postcss.config.js", "./webpack.config.js", "./elm.json", "./"]
COPY ["./src", "./src"]
COPY ["./assets", "./assets"]
RUN ["npm", "run", "build"]


FROM scratch AS static

COPY --from=build ["/md/dist", "/"]


FROM --platform=$TARGETPLATFORM nginx:mainline-alpine AS nginx

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF

EXPOSE 8080

LABEL org.opencontainers.image.created=${BUILD_DATE}
LABEL org.opencontainers.image.url="https://github.com/Lattyware/massivedecks"
LABEL org.opencontainers.image.source="https://github.com/Lattyware/massivedecks"
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.revision=${VCS_REF}
LABEL org.opencontainers.image.vendor="Reread Games <team@rereadgames.com>"
LABEL org.opencontainers.image.licenses="AGPL-3.0+"
LABEL org.opencontainers.image.title="Massive Decks (Client)"
LABEL org.opencontainers.image.description="The web client for Massive Decks, a comedy party game."

COPY --from=static ["/", "/usr/share/nginx/html/"]
COPY ["./nginx.conf", "/etc/nginx/nginx.conf"]
