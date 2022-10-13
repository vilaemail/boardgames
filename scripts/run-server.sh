#!/bin/bash

sudo systemctl start docker
cd nakama/server-code
npm install
npx tsc
cp ./build/*.js ../data/modules/
cd ..
sudo docker compose up
sudo docker compose down
sudo systemctl stop docker
sudo iptables -F
sudo iptables-restore < /etc/iptables/iptables.rules
cd ..
