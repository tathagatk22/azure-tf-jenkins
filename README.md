# azure-tf-jenkins

User can use this repository to create compute service instance and it's required components on Azure cloud.

### Perform the below steps to create instance

```
$ git checkout https://github.com/tathagatk22/azure-tf-jenkins.git

# Fill all the appropiate values in terraform.tfvars

$ terraform init
$ terraform plan
$ terraform apply --auto-approve
$ terraform output public_ip
```
##### Output

A Public IP will be allocated to the instance 
```
XX.XX.XX.XX
```

### Perform these next step by taking SSH session

```
$ sudo apt-get update -y
$ sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
$ sudo apt-get update -y
$ sudo apt install docker.io -y
$ sudo docker network create jenkins
$ sudo docker container run --name jenkins --network jenkins --detach -v /root/jenkins/data:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock:ro --restart on-failure -u 0 -p 80:8080 docker.io/tathagatk22/cd-helper:v2
$ sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```
#### Output for the initialAdminPassword

7XXXXa999XXXXb9bXXXX963XXX85XXX

### Jenkins Server is ready

Now Jenkins server will be accessible on XX.XX.XX.XX:80 and then we have to insert the above command's output to login as a admin user and setup the initial phase for Jenkins Server.

### Dockerfile

This docker image is created with the help of jenkinsci/blueocean:1.22.0 with additional command line utilities such as kubectl and terraform.

```
docker.io/tathagatk22/cd-helper:v2
```