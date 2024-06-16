# Express App

## Docker

You can also run this application in a Docker conatiner.  
**Using Dockerfile manually**
Here we build the docker image and run the docker container manually.

1. Build the docker image

```bash
$ cd express-app
$ docker build -t express-app/0.0.1  .
```

2. Run the docker container

```bash
$ docker run -p 8095:8083 express-app/0.0.1
```

Or you can run the container in detadched mode

```bash
$ docker run -it -p 8095:8083 express-app/0.0.1
```

3. Test the application on your browser by going to `http://localhost:8095` with your browser.

**Using Docker-compose with Dockerfile**  
To build the docker image and run the docker container using `docker-compose.yml` file.

```bash
$ cd express-app
$ docker-compose up
```
