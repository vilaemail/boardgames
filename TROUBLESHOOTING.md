# Troubleshooting

Below is a list of steps you might take to solve your problem. If you solved a problem which is not listed here you can add it, by folling the [CONTRIBUTING](./CONTRIBUTING) guidelines.

## Reference: Docker troubleshooting

Delete all containers and images:
```
sudo docker rm $(sudo docker ps --filter status=exited -q)
sudo docker ps
sudo docker rm <any-remaining-container-id>
sudo docker rmi $(sudo docker images -a --filter=dangling=true -q)
```

## Reference: Manually running multiplayer server
1. Start docker `sudo systemctl start docker` then `sudo systemctl status docker` (if you updated kernel reboot is needed). Since docker is changing iptables rules it is advised not to `enable` the service but only start it when needed.
1. Compile/copy TS code for usage by nakama server
    ```
    cd nakama/server-code
    npm install
    npx tsc
    cp ./build/*.js ../data/modules/
    cd ..
    ```
1. Run server `sudo docker compose up`
1. Server will run and you can access its console via `http://127.0.0.1:7351` and credentials `admin:password`.
1. Clean-up:
    ```
    Ctrl+C to stop docker compose
    sudo docker compose down
    sudo systemctl stop docker
    sudo iptables -F
    sudo iptables-restore < /etc/iptables/iptables.rules
    ```