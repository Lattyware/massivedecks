#!/bin/bash
docker login
docker-compose build --no-cache
docker push rfuehrer/massivedecks-client:dev
docker push rfuehrer/massivedecks-server:dev
docker-compose up
