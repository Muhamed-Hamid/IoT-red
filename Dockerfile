FROM nodered/node-red-docker
RUN npm install node-red-node-wordpos

USER root

COPY node-red /data

ENV FLOWS /data/flows_DESKTOP-B30PKJ2.json /data/flows_DESKTOP-B30PKJ2_cred.json

EXPOSE 1880
