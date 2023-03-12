# Cyberduck12032023
AWS infrastructure deploying a VPC, Ec2 instances with ASG, Mysql RDS using terraform

## Prerequisites:
- vpc
- subnets with public & private
- security groups for rds & ec2 instances
- AMI with prebaked ssm manager or using bastion setup to connect to instnaces
- Rds deployment
- Lb in public subnet.

## LB
I have a load balancer deployed in public subnet and using listener rules will forward traffic to instances on private subnet.

Our lb security is setup in such way, that is allows all traffic to lb. In real infra, we use Route 53 to point to lb and only allow 443 traffic. 

Traffic is forwarded to target groups instances and the instances are deployed via ASG to maintain min req/desired instances always to serve the traffic.

## EC2
Once we jump on to the EC2 instance servers, we have connectivity to RDS allowed via Sgs to private subnets using SQL connectivity on server and it will talk to RDS.

## RDS

For deployment, I have chosen smallest instance to test locally, however in real infra I would select m4/m5/m6a instance types depends on server read requests and environment

## Additional Info:

I can further improvise system with NACLS, RDS-IAM integration to create RDS users & roles. As the task was to showcase deployment of RDS to support e-commerce website, we can select load intense instance types for RDS such as db.m5.4xlarge with read replicas & for EC2 such as M5.2Xlarge with 3 instances
I have used hard coded values in the files but it will be good to use default values in variables.tf and values in tfvars file. There is lot of scope for improvement in this area but due to time factor I have used hard coded values.

## Security group

I have created security groups for mysql rds, Asg sg, ssm_https sg, EC2 sg

## Commands
terraform init
terraform plan
terraform apply 
terraform destroy

## Research work:
To do this task first I have launch the infrastructure using GUI in a free tier amazon account and then I have replicated the steps on my terraform file.
I have used modules repo for creating vpc. I have refered terraform git repo for documentation