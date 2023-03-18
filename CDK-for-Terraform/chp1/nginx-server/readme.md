# Nginx Server  
__Description__  
This project provisions a docker container running NGINX server using Docker Desktop.  
The provider used was _kreuzwerker/docker_ and with a local state. 

__Deploy__  
```
$ cdktf deploy
```

__Testing__  
To test the deployed resource access localhost on port 8000 user a browser or curl.
```
$ curl localhost:8000
```  
The should show you the Nginx default page.   
You can also check the container using the `docker ps` command  
```
$ docker ps
```  

__Clean up__  
```
$ cdktf destroy
```  
Select the _Approve_ option when prompted.  
