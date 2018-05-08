# Description

This doc describe a simple example to create docker container with state
(_statefull_), shutdown one swarn node and check that state is preserved in
other node.

# Steps

**Note** Run directory should be _Project root_, that is path of `Vagrantfile`

1. Connect to worker and create _volume path_

   ```bash
   vagrant ssh -c "sudo mkdir -p /swarm/volumes/web-stateless" worker1
   ```

1. Connect to manager

   ```bash
   vagrant ssh manager
   ```

1. Create docker service with status

   ```bash
   docker service create \
    --detach \
    --name web-stateless \
    --constraint 'node.role == worker' \
    --mount type=bind,source=/swarm/volumes/web-stateless,target=/data \
    -p 8000:8000 \
    python:3 \
      /bin/bash -c "\
        [[ -f /data/index.html ]] || echo \"<html><body>Created at $(date)</body></html>\" > /data/index.html; \
        cd /data; \
        python -m http.server 8000 \
      "
    ```

1. Wait for service will be up. You can check with:

   ```bash
   docker service ps web-stateless
   ```

   Annotate name of which _worker node_  are running the container. For example:

   ```
   ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE           ERROR               PORTS
   q96yon4tht4q        web-stateless.1     python:3            worker1             Running             Running 2 minutes ago
   ```

   `worker1` in this case

1. Checks that service is exposed in manager with data about creation time

  ```bash
  curl localhost:8000/index.html
  ```

  Output expected (Timestamp will vary):

  ```html
  <html><body>Created at Tue May  8 16:24:13 UTC 2018</body></html>
  ```

1. Remove _worker node_ that now is hosting our service.

   ```bash
   docker service ps web-stateless | awk '$5~/Running/{print $4}' | xargs docker node rm -f
   ```

1. Checks that service is up with `docker service ps web-stateless`


  Output example (Note State is **Ready**):

  ```
  ID                  NAME                  IMAGE               NODE                        DESIRED STATE       CURRENT STATE           ERROR               PORTS
  r09n8jb71wjd        web-stateless.1       python:3            worker2                     Ready               Ready 3 seconds ago
  q96yon4tht4q         \_ web-stateless.1   python:3            nfr74ezs1i156a2o72bhggrha   Shutdown            Running 7 minutes ago
  ```


1. Checks service and validate that timestamp is the same:
   ```bash
   curl localhost:8000/index.html
   ```

   Output expected (Timestamp same as 3 steps back):

   ```html
   <html><body>Created at Tue May  8 16:24:13 UTC 2018</body></html>
   ```
