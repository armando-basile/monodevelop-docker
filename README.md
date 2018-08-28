# monodevelop-docker
Dockerfile for Mono 5, .Net Core 2 and Monodevelop 7


to build image locally copy Dockerfile in a folder and use 
```
$ sudo docker build \
 --build-arg HTTP_PROXY="<host>:<port>" \
 --build-arg HTTPS_PROXY="<host>:<port>" \
 -t armandob/monodevelop-docker . 
```
_NB: do not forget the point at the end_


to run image use
```
$ sudo docker run \
 --name monodevelop-docker-container \
 -it --rm \
 -e "DISPLAY=$DISPLAY" \
 -e "HTTP_PROXY=<host>:<port>" \
 -e "HTTPS_PROXY=<host>:<port>" \
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
_to add a single host to ip mapping use_ ```--add-host=<host>:<ip_address>``` _es:_ ```--add-host=addins.monodevelop.com:40.123.47.58```


to change gtk theme settings use follow command (while is running image)
```
$ sudo docker exec -it monodevelop-docker-container lxappearance

```
