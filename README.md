# wireguard

Tools and docs for setting up wireguard.

## contents
- [`bin`](./bin/)
  - [`pods.ah`](./bin/pods.sh) - launches a few Ubuntu nodes with init.sh script
- [`shared`](./shared/) - shared volume mounted to all containers for accessing init.sh script and writing to log files

## reaching a node
Each node will advertise itself on port `800x`, where `x` is the node number. For example, `node-2` can be reached at:
```sh
curl localhost:8002/self/me.txt
```
