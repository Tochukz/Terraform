aws ecr get-login-password | docker login --username AWS --password-stdin 314146339647.dkr.ecr.eu-west-2.amazonaws.com/simple-express-repo 

docker tag express-app:latest 314146339647.dkr.ecr.eu-west-2.amazonaws.com/simple-express-repo:latest

docker push 314146339647.dkr.ecr.eu-west-2.amazonaws.com/simple-express-repo:latest