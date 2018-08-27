# monodevelop-docker
Dockerfile for monodevelop build


to build image locally use:
```$ sudo docker build -t armandob/monodevelop-docker-local . ```

_NB: do not forget the point at the end_


to run image locally use
```
$ sudo docker run \
 -it --rm \
 -e "DISPLAY=$DISPLAY" \
 -u $(id -u) \
 -v /tmp:/tmp \
 -v /home:/home/$USER \
 -v /etc/group:/etc/group:ro \
 -v /etc/passwd:/etc/passwd:ro \
 -v /etc/shadow:/etc/shadow:ro \
 -v /etc/sudoers.d:/etc/sudoers.d:ro \
 -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
 armandob/monodevelop-docker-local

```

