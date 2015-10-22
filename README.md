docker-alpinejenkins
================

Uses the Alpine image and sets up a container with [Jenkins](http://jenkins-ci.org/) installed.

This Jenkins Docker is configured best to support chef cookbooks and ruby based building/testing.

## Usage

```
docker run -p 8080:8080 -p 50000:50000 jenkins
```

This will store the workspace in /var/jenkins_home. All Jenkins data lives in there - including plugins and configuration.
You will probably want to make that a persistent volume (recommended):

```
docker run -p 8080:8080 -p 50000:50000 -v /your/home:/var/jenkins_home jenkins
```

This will store the jenkins data in `/your/home` on the host.
Ensure that `/your/home` is accessible by the jenkins user in container (jenkins user - uid 1000) or use `-u some_other_user` parameter with `docker run`.


You can also use a volume container:

```
docker run --name myjenkins -p 8080:8080 -p 50000:50000 -v /var/jenkins_home jenkins
```

## Building

To build the image, do the following:

```
% docker build github.com/hearstat/docker-alpinejenkins
```

A prebuilt container is available in the docker index.

```
% docker pull hearstat/alpine-jenkins
```
