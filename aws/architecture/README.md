# AWS cloud infrastructure architecture

![Architecture](AWS-Architecture.png)

## Explanations
### Region and VPC
eu-north-1 \(in Stockholm\) was chosen because it's the nearest, 2 Availability Zones were chosen for high availability of backend servers \(RDS and ElastiCache would be multiplicated too but Free Tier does not include it\).\
VPC consists of a public subnet in master availability zone, private networks are in 2 different availability zones, one is for master services, the other is for standby backend servers.
### Security Groups
Each service type will have own security group which, following Principle of Least Privilege, will allow for necessary network traffic between services or users requests \(protocols, ports and sources\).

Main communication flow:
* Users connect to application by domain name that is resolved by Route 53.
* Route 53 routes to CloudFront to serve website.
* CloudFront serves cached website or requests it from S3 bucket. CloudFront proxies requests to backend's ALB.
* ALB distributes load to backend containers ran by ECS service that uses Auto Scaling Group of EC2 instances as infrastructure.
* Backend containers communicate with ElastiCache to access RDS database.
* ElastiCache accesses RDS database to take actions on application's data.

Other communication:
* CloudFront and ALB communicate with ACM that provides them certificate \(for CloudFront issued in us-east-1 region\).
* CloudWatch uses metrics from all services.
* Public subnet communicates with Internet Gateway to access internet.
* Private subnets communicate with NAT Gateway to access internet \(optional\).
* Services from private subnets communicate with VPC Endpoints to access regional services.
### IAM
All actions will be taken from IAM user account that has proper permissions to manage whole architected infrastructure.\
Each service type will have own role which, following Principle of Least Privilege, will have permissions for only needed actions to perform their tasks.
### Secrets Manager and KMS
Secrets Manager will manage secrets for backend application and RDS database.\
KMS will manage any needed keys for Secrets Manager and used services \(AWS-managed keys\).
### ACM
ACM will manage free, public certificates for CloudFront and ALB.
### Route Tables
Route Tables are divided on Public and Private where both handle local network traffic and also public table routes to Internet Gateway and private table routes to NAT Gateway.
### Internet Gateway
Internet Gateway will allow public subnets for communication with internet.
### NAT Gateway
NAT Gateway will be located in master public subnet and serve for private subnets to connected them internet. If NAT Gateway won't be needed it will be removed because of costs.
### VPC Endpoints
VPC Endpoints will be used for connecting services in private \(maybe in public too\) subnets \(EC2, RDS, ElastiCache\) to regional services \(ECR, KMS, Secrets Manager\).
### ALB
Application Load Balancer will be used to distribute traffic to ECS containers in Auto Scaling EC2 group.
### CloudWatch
CloudWatch monitors and observes all services with defined up to 10 alarms when something goes wrong.
### Auto Scaling
Backend Free-Tiered EC2 servers will be used for running application containers with ECS.\
They will be auto-scaled from 1 to 2 instances based on CPU/memory usage or failure of a master instance. Auto scaling will be distributed between 2 AZs.
### ECS
ECS will be used to run backend application in containers using auto scaled EC2 infrastructure.
### Route 53
DNS will route domain name \(if bought or obtained\) to CloudFront.
### CloudFront
CDN will be used for distributing website across the web. Origin will be sourced from S3. Backend requests will be proxied to ALB.
### ECR
ECR will be used for storing backend Docker image and serving it for EC2 instances.
### ElastiCache
One cache.t3.micro node ElastiCache \(ValKey, Redis or Memcached\) will be used for caching RDS database responses.
### RDS
PostgreSQL single-AZ db.t4g.micro instance with 20 GiB of gp2 storage will be used for database services for application.
