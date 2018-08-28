# monodevelop-docker
Dockerfile for monodevelop build


to build image locally copy Dockerfile in a folder and use 
```
$ sudo docker build -t armandob/monodevelop-docker . 
```
_NB: do not forget the point at the end_


to run image use
```
$ sudo docker run \
 --name monodevelop-docker-container \
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
 armandob/monodevelop-docker

```


to change gtk theme settings use follow command (while is running image)
```
$ sudo docker exec -it monodevelop-docker-container lxappearance

```
