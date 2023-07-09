# Building and Configuring Fargate with RDS Using Terraform | DevelopersIO
In the previous blog I wrote about the ALB and ECS settings, in this blog I will extend that by adding the RDS database.

### Introduction:

Infrastructure as Code (IaC) has become an essential practice for automating the deployment and management of cloud resources. One common scenario is setting up a scalable and resilient application architecture using AWS Fargate and Amazon RDS. In this article, we will explore how to create and configure Fargate with RDS using Terraform, a popular IaC tool.

#### 1\. What is AWS Fargate?

AWS Fargate is a serverless compute engine for containers provided by Amazon Web Services (AWS). It allows developers to run containers without the need to manage the underlying infrastructure. Fargate offers a flexible and scalable solution for deploying containerized applications, ensuring high availability and ease of management.

#### 2\. What is Amazon RDS?

Amazon RDS (Relational Database Service) is a managed database service offered by AWS. It supports various database engines such as MySQL, PostgreSQL, and Amazon Aurora. RDS takes care of routine database administration tasks, including backups, software patching, and automatic scaling, enabling developers to focus on application development rather than database management.

### Prerequisites

Before getting started, ensure that you have the following prerequisites in place: - An AWS account with appropriate permissions to create and manage Fargate and RDS resources. - Terraform installed on your local machine. - Basic knowledge of AWS services, Fargate, RDS, and Terraform.

### Architeture Diagram

![](https://d1tlzifd8jdoy4.cloudfront.net/wp-content/uploads/2023/06/Untitled2-1-640x436.png)

### Setting up the Environment

To begin, you need to set up your development environment. This includes configuring AWS credentials on your machine and initializing a Terraform project.

#### 1\. Networking and Security Considerations

Networking plays a crucial role in connecting the Fargate containers with the RDS database instance. We need to define appropriate security groups, subnets, and VPC settings to allow communication between the Fargate tasks and the RDS database.

##### Networking

**VPC**


|VPC Name   |CIDR       |Tenancy|enable_dns_hostnames|enable_dns_support|Remarks|
|-----------|-----------|-------|--------------------|------------------|-------|
|dio-dev-vpc|10.0.0.0/16|default|true                |true              |       |


**Subnets**



* Subnet Name: dio-dev-private-subnet-1
    * Availability Zone: ap-northeast-1a
    * CIDR: 10.0.16.0/20
    * Route Table: Private-Route-Table
    * Tag: Tier: Private
    * Remarks: Internet connection via   Nat Gateway
* Subnet Name: dio-dev-private-subnet-2
    * Availability Zone: ap-northeast-1c
    * CIDR: 10.0.32.0/20
    * Route Table: Private-Route-Table
    * Tag: Tier: Private
    * Remarks: Internet connection via Nat Gateway
* Subnet Name: dio-dev-public-subnet-1
    * Availability Zone: ap-northeast-1a
    * CIDR: 10.0.48.0/20
    * Route Table: Public-Route-Table
    * Tag: Tier: Public
    * Remarks: Internet connection via Internet Gateway
* Subnet Name: dio-dev-public-subnet-2
    * Availability Zone: ap-northeast-1c
    * CIDR: 10.0.64.0/20
    * Route Table: Public-Route-Table
    * Tag: Tier: Public
    * Remarks: Internet connection via Internet Gateway
* Subnet Name: dio-dev-isolated-Subnet-1
    * Availability Zone: ap-northeast-1a
    * CIDR: 10.0.80.0/20
    * Route Table: Isolated-Route-Table
    * Tag: Tier: Isolated
    * Remarks:
* Subnet Name: dio-dev-isolated-Subnet-2
    * Availability Zone: ap-northeast-1c
    * CIDR: 10.0.96.0/20
    * Route Table: Isolated-Route-Table
    * Tag: Tier: Isolated
    * Remarks:


**Internet Gateway**


|Item        |Value      |Remarks|
|------------|-----------|-------|
|Name        |dio-dev-igw|       |
|Attached VPC|dio-dev-vpc|       |


**NAT Gateway**


|Item        |Value                  |Remarks|
|------------|-----------------------|-------|
|Name        |dio-dev-ngw            |       |
|Attached VPC|dio-dev-vpc            |       |
|Subnet      |dio-dev-public-subnet-1|       |


**Private-Route-Table**


|Item              |Value                                            |Remarks|
|------------------|-------------------------------------------------|-------|
|Name              |dio-dev-private-route-table                      |       |
|VPC               |dio-dev-production-vpc                           |       |
|Subnet Association|dio-dev-private-subnet-1 dio-dev-private-subnet-2|       |


**Routes for Private Route-Table**


|recipient  |target     |status|propagated|remarks|
|-----------|-----------|------|----------|-------|
|10.0.0.0/16|local      |active|no        |       |
|0.0.0.0/0  |dio-dev-ngw|active|no        |       |


**Public-Route-Table**


|Item              |Value                                          |Remarks|
|------------------|-----------------------------------------------|-------|
|Name              |dio-dev-public-route-table                     |       |
|VPC               |dio-dev-vpc                                    |       |
|Subnet Association|dio-dev-public-subnet-1 dio-dev-public-subnet-2|       |


**Routes for Public Route-Table**


|recipient  |target     |status|propagated|remarks|
|-----------|-----------|------|----------|-------|
|10.0.0.0/16|local      |active|no        |       |
|0.0.0.0/0  |dio-dev-igw|active|no        |       |


**Isolated-Route-Table**


|Item              |Value                                              |Remarks|
|------------------|---------------------------------------------------|-------|
|Name              |dio-dev-isolated-route-table                       |       |
|VPC               |dio-dev-vpc                                        |       |
|Subnet Association|dio-dev-isolated-subnet-1 dio-dev-isolated-subnet-2|       |


**Routes for Isolated Route-Table**


|recipient  |target|status|propagated|remarks|
|-----------|------|------|----------|-------|
|10.0.0.0/16|local |active|no        |       |


### main.tf(networking)

```

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
  backend s3 {
        key="PROD/infrastructure.tfstate"
        bucket="developersio-ecs-farget"
        region="ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

## Data
data "aws_availability_zones" "az" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

## VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "dio-dev-vpc"
  }
}


resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_vpc.vpc.id
  for_each          = var.private_subnets
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.value)
  availability_zone = each.key

  tags = {
    Name   = "dio-dev-private-subnet-${each.value == 1 ? "1" : "2"}"
        Tier = "Private"
  }
}

resource "aws_subnet" "public_subnets" {
  vpc_id            = aws_vpc.vpc.id
  for_each          = var.public_subnets
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.value)
  availability_zone = each.key

  tags = {
    Name   = "dio-dev-public-subnet-${each.value == 3 ? "1" : "2"}"
    Tier = "Public"
  }
}

## Internet Gateway

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "dio-dev-igw"
  }
}

## Elastic IP for Nat Gateway

resource "aws_eip" "eip_natgateway" {
  vpc        = true
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "dio-dev-ngw-eip"
  }
}

## Nat Gateway

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip_natgateway.id
  subnet_id  = aws_subnet.public_subnets[element(keys(aws_subnet.public_subnets), 0)].id #Accessing an specific value inside a for_each
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "dio-dev-ngw"
  }
}

## Route Tables

resource "aws_route_table" "private_subnets_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = local.internet
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "    dio-dev-private-route-table"
  }
}

resource "aws_route_table_association" "private_subnet_route_association" {
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_subnets_route_table.id
}

resource "aws_route_table" "public_subnets_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = local.internet
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "    dio-dev-public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_route_association" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_subnets_route_table.id
}

# new Subnet for RDS
resource  "aws_subnet" "isolated_subnets" {
  vpc_id            = aws_vpc.vpc.id
  for_each          = var.isolated_subnets
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.value)
  availability_zone = each.key

  tags = {
    Name   = "dio-dev-isolated-subnet-${each.value == 5 ? "1" : "2"}"
    Tier = "Isolated"
  }
}

## Route Tables
resource "aws_route_table" "isolated_subnets_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "    dio-dev-isolated-route-table"
  }
}

resource "aws_route_table_association" "isolated_subnet_route_association" {
  for_each       = aws_subnet.isolated_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.isolated_subnets_route_table.id
}

```


#### Creating the Fargate Task Definition

The Fargate task definition defines the containerized application that will run on Fargate. It specifies details such as the Docker image, CPU and memory requirements, network configuration, and environment variables.

**Cluster**


|Property                      |Value                                             |Remarks|
|------------------------------|--------------------------------------------------|-------|
|Cluster Name                  |dio-dev-ecs-cluster                               |       |
|VPC                           |dio-dev-vpc                                       |       |
|Subnets                       |dio-dev-private-subnet-1, dio-dev-private-subnet-2|       |
|Capacity Provider             |No default found                                  |       |
|Container Insights            |true                                              |       |
|Services                      |1                                                 |       |
|Registered container instances|0                                                 |       |


**Service**



* Property: Service Name
    * Value: dio-dev-ecs-service
    * Remarks:
* Property: Service type
    * Value: REPLICA
    * Remarks:
* Property: Launch Type
    * Value: Fargate
    * Remarks:
* Property: Application Type
    * Value: Service
    * Remarks: Deployment method for tasks (whether to include tasks in a service)
* Property: Task Definition
    * Value: dio-dev-td
    * Remarks:
* Property: Desired Tasks
    * Value: 1
    * Remarks: To be deployed in 1 Availability Zones
* Property: VPC
    * Value: dio-dev-vpc
    * Remarks:
* Property: Subnets
    * Value: dio-dev-private-subnet-1, dio-dev-private-subnet-2
    * Remarks:
* Property: Security Group
    * Value: dio-dev-task
    * Remarks:
* Property: Auto assign Public IP
    * Value: false
    * Remarks:
* Property: Load Balancer Type
    * Value: Application Load Balancer
    * Remarks:
* Property: Load Balancer Name
    * Value: dio-dev-ecs-alb
    * Remarks:
* Property: Target Group
    * Value: dio-dev-ecs-tg
    * Remarks:
* Property: Container Name
    * Value: dio-container
    * Remarks: Container name to be connected to ALB
* Property: Port Number
    * Value: 80
    * Remarks: Port number used for connection to ALB


**Task Definition**


|Property            |Value     |Remarks|
|--------------------|----------|-------|
|Task Definition Name|dio-dev-td|       |


**Container Configuration**


|Property                     |Value                 |Remarks                         |
|-----------------------------|----------------------|--------------------------------|
|Container Name               |dio-dev-ecs-container |                                |
|Image URI                    |httpd:latest          |                                |
|Port                         |80                    |Port for connection with ALB    |
|Protocol                     |TCP                   |Protocol for connection with ALB|
|Essential Containers         |Yes                   |                                |
|Application Environment      |Fargate               |                                |
|Operating System/Architecture|Linux/ARM64           |                                |
|CPU                          |1 vCPU                |                                |
|Memory                       |2 GB                  |                                |
|Task Role                    |dio-dev-task-role     |                                |
|Execution Role               |dio-dev-task-exec-role|                                |
|Network Mode                 |awsvpc                |                                |


**IAM Role**


|Property   |Value                           |Remarks           |
|-----------|--------------------------------|------------------|
|Role Name  |dio-dev-task-exec-role          |                  |
|Policy Name|AmazonECSTaskExecutionRolePolicy|AWS managed policy|



|Property   |Value                                                          |Remarks           |
|-----------|---------------------------------------------------------------|------------------|
|Role Name  |dio-dev-task-role                                              |                  |
|Policy Name|AmazonECSTaskExecutionRolePolicy , AmazonSSMManagedInstanceCore|AWS managed policy|


**Trust Policy**

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"


    }
  ]
}
```


**Security Group**



* Property: Security Group Name
    * Value: dio-ecs-cluster-sg
    * Remarks:
* Property: Inbound Rules
    * Value:
    * Remarks:
* Property: Rule 1
    * Value: Protocol: TCP, Port Range: 80, Source: Anywhere (0.0.0.0/0)
    * Remarks: Allows inbound traffic on port 80 from any source
* Property: Outbound Rules
    * Value:
    * Remarks:
* Property: Rule 1
    * Value: Protocol: All Traffic, Destination: 0.0.0.0/0
    * Remarks: Allows outbound traffic to any destination
* Property: Rule 2
    * Value: Protoco: All Traffic, IP version :IPv6 ,Destination: ::/0
    * Remarks: Allows outbound traffic to any destination




* Property: Security Group Name
    * Value: dio-dev-task
    * Remarks:
* Property: Inbound Rules
    * Value:
    * Remarks:
* Property: Rule 1
    * Value: Protocol: TCP, Port Range: 80, Source:dio-dev-ecs-sg
    * Remarks: Allows inbound traffic on port 80 from any source
* Property: Outbound Rules
    * Value:
    * Remarks:
* Property: Rule 1
    * Value: Protocol: All Traffic, IP version :IPv4 ,Destination: 0.0.0.0/0
    * Remarks: Allows outbound traffic to any destination
* Property: Rule 2
    * Value: Protoco: All Traffic, IP version :IPv6 ,Destination: ::/0
    * Remarks: Allows outbound traffic to any destination


Configure the Load Balancer this will distribute the task between multiple task or cluster

### Application Load Balancer


|Item                          |Value                                            |Remarks|
|------------------------------|-------------------------------------------------|-------|
|Type                          |ALB                                              |       |
|ELB Name                      |dio-dev-ecs-alb                                  |       |
|Subnet                        |dio-dev-public-subnet-1 , dio-dev-public-subnet-2|       |
|Security Group                |dio-ecs-cluster-sg                               |       |
|Listener                      |HTTP:80                                          |       |
|Deletion Protection           |Disabled                                         |       |
|Idle Timeout                  |60 seconds                                       |       |
|HTTP/2                        |Enabled                                          |       |
|Desync Mitigation Mode        |Defensive                                        |       |
|Drop Invalid Header Fields    |Disabled                                         |       |
|Access Logs                   |Disabled                                         |       |
|Preserve host header          |Disabled                                         |       |
|Client port preservation      |Disabled                                         |       |
|TLS version and cipher headers|off                                              |       |


**Listners**


|Path   |Target        |Security Policy|SSL Certificate|Notes|
|-------|--------------|---------------|---------------|-----|
|Default|dio-dev-ecs-tg|NA             |NA             |     |


**TargetGroup**


|Item                |Configuration Value|Notes|
|--------------------|-------------------|-----|
|Target Group Name   |dio-dev-ecs-tg     |     |
|Port                |http:80            |     |
|Protocol version    |HTTP1              |     |
|Deregistration Delay|300 seconds        |     |
|Stickiness          |Disabled           |     |
|Targets             |IP Address         |     |


### main.tf(ECS)

```

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend s3 {
        key="PROD/ECS.tfstate"
        bucket="developersio-ecs-farget"
        region="ap-northeast-1"
  }
}



provider "aws" {
  region  = "ap-northeast-1"
}

## Data
data "aws_vpc" "vpc_id" {
  filter {
    name   = "tag:Name"
    values = ["dio-dev-vpc"]
  }
  lifecycle {
    postcondition {
      condition     = self.enable_dns_support == true
      error_message = "The selected VPC must have DNS support enabled."
    }
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "tag:Tier"
    values = ["Private"]
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "tag:Tier"
    values = ["Public"]
  }
}

## ECS Cluster

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

## ECS IAM Role

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name                = var.ecsTaskExecutionRole_name
  path                = "/"
  managed_policy_arns = local.managedpolicies_AmazonECSTaskExecutionRolePolicy

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Sid    = ""
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}





## Tak role

resource "aws_iam_role" "ecsTaskRole" {
  name                = var.ecsTaskRole_name
  path                = "/"
  managed_policy_arns = local.managedpolicies_AmazonECSTaskRolePolicy

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Sid    = ""
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}


## Security Groups

resource "aws_security_group" "alb_ingress" {
  name        = var.alb_ingress_name
  description = "Ingress traffic from Internet"
  vpc_id      = data.aws_vpc.vpc_id.id

  dynamic "ingress" {
    for_each = var.alb_ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = local.tcp_protocol
      cidr_blocks = local.all_ips_ipv4
    }
  }

  egress {
    from_port        = local.any_port
    to_port          = local.any_port
    protocol         = local.any_protocol
    cidr_blocks      = local.all_ips_ipv4
    ipv6_cidr_blocks = local.all_ips_ipv6
  }
}

resource "aws_security_group" "ecs_fargate_task_ingress" {
  name        = var.ecs_fargate_task_sg
  description = "Ingress traffic from ALB to Fargate task"
  vpc_id      = data.aws_vpc.vpc_id.id

  ingress {
    description     = "HTTP Port"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_ingress.id]
  }

  egress {
    from_port        = local.any_port
    to_port          = local.any_port
    protocol         = local.any_protocol
    cidr_blocks      = local.all_ips_ipv4
    ipv6_cidr_blocks = local.all_ips_ipv6
  }
}

### Fargate Task_Definition

resource "aws_ecs_task_definition" "fargate_task_definition" {
  family                   = var.fargate_task_definition_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.fargate_task_definition_cpu
  memory                   = var.fargate_task_definition_memory
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskRole.arn

  container_definitions = jsonencode([{
    name      = "${var.ecs_container_name}"
    image     = "${var.fargate_task_definition_image}"
    essential = true
    portMappings = [{
      protocol      = "tcp"
      containerPort = 80
      hostPort      = 80
    }]
    }]
  )

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

## Amazon ECS Service

resource "aws_ecs_service" "ecs_fargate" {
  name                   = var.ecs_service_name
  cluster                = aws_ecs_cluster.ecs_cluster.id
  task_definition        = aws_ecs_task_definition.fargate_task_definition.id
  desired_count          = var.desired_task_count
  enable_execute_command = true
  scheduling_strategy    = "REPLICA"
  launch_type            = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.private_subnets.ids
    security_groups  = [aws_security_group.ecs_fargate_task_ingress.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_alb_target_group.arn
    container_name   = var.ecs_container_name
    container_port   = 80
  }
}

## ALB

resource "aws_lb" "ecs_alb" {
  name                   = var.alb_name
  internal               = false
  load_balancer_type     = "application"
  security_groups        = [aws_security_group.alb_ingress.id]
  subnets                = data.aws_subnets.public_subnets.ids
  idle_timeout           = 60
  enable_http2           = true
  desync_mitigation_mode = "defensive"
}

## ALB Target Group

resource "aws_lb_target_group" "ecs_alb_target_group" {
  name                          = var.alb_target_group_name
  target_type                   = "ip"
  port                          = 80
  protocol                      = "HTTP"
  vpc_id                        = data.aws_vpc.vpc_id.id
  load_balancing_algorithm_type = "round_robin"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
  }
}

## ALB Target Group Listerner

resource "aws_alb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_alb_target_group.arn
  }
}

```


### Configuring the RDS Database Instance

Next, we configure the RDS database instance that will be used by our application. This involves specifying the database engine, instance type, storage, username, password, and other parameters.

**DB Instance Settings**


|Item                        |Setting Value            |Remarks|
|----------------------------|-------------------------|-------|
|DB Name                     |diodb                    |       |
|Storage                     |10GB                     |       |
|Automatic Scaling of Storage|Disabled                 |       |
|Instance Type               |db.t3.micro              |       |
|Security Group              |dio-dev-db-sg            |       |
|Multi-AZ                    |false                    |       |
|AZ                          |ap-northeast-a           |       |
|Port Number                 |3306                     |       |
|Master Username             |dioadmin                 |       |
|Database authentication     |Password                 |       |
|Performance_insights enabled|false                    |       |
|Storage type                |General Purpose SSD (gp2)|       |
|Parameter Group             |dio-dev-db-pg            |       |
|Option Group                |Default                  |       |


**DB engine settings**


|Parameter Name                     |Setting Value        |Remarks  |
|-----------------------------------|---------------------|---------|
|Database Type                      |MySQL                |         |
|Character Encoding                 |utf-8                |         |
|Backup Retention Period (1-35 days)|35                   |         |
|Backup Window                      |03:00-06:00          |UTC (GMT)|
|Maintenance Window                 |"mon:00:00-mon:03:00"|UTC (GMT)|
|Auto Minor Version Upgrade         |false                |         |
|Deletion protection                |Disabled             |         |


**Parameter Group**


|Field               |Content      |Remarks|
|--------------------|-------------|-------|
|name                |dio-dev-db-pg|       |
|character_set_server|utf8         |       |
|character_set_client|utf8         |       |


**Subnet Group**


|Field     |Content                                            |Remarks|
|----------|---------------------------------------------------|-------|
|name      |dio-dev-db-subnet                                  |       |
|subnet_ids|dio-dev-isolated-subnet-1 dio-dev-isolated-subnet-2|       |


**Security Group**



* Property: Security Group Name
    * Value: dio-dev-db-sg
    * Remarks:
* Property: Inbound Rules
    * Value:
    * Remarks:
* Property: Rule 1
    * Value: Protocol: TCP, Port Range: 3306, Source: 10.0.0.0/16
    * Remarks: Allows inbound traffic on port 80 from any source
* Property: Outbound Rules
    * Value:
    * Remarks:
* Property: Rule 1
    * Value: Protocol: All Traffic, Destination: 0.0.0.0/0
    * Remarks: Allows outbound traffic to any destination
* Property: Rule 1
    * Value: Protocol: All Traffic,IP version IPv6, Destination: ::/0
    * Remarks: Allows outbound traffic to any destination


### main.tf(RDS)

```

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend s3 {
        key="PROD/RDS.tfstate"
        bucket="developersio-ecs-farget"
        region="ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

## Data

data "aws_vpc" "vpc_id" {
  filter {
    name   = "tag:Name"
    values = ["dio-dev-vpc"]
  }
}

data "aws_subnets" "isolated_subnets" {
  filter {
    name   = "tag:Name"
    values = ["Isolated"]
  }
}

data "aws_subnet_ids" "isolated_subnets_ids" {
  vpc_id = data.aws_vpc.vpc_id.id
  filter {
    name   = "tag:Tier"
    values = ["Isolated"]
  }
}

## Security Groups

resource "aws_security_group" "rdssql_ingress" {
  name        = var.rdssql_ingress_name
  description = "Ingress traffic from Private subnets"
  vpc_id      = data.aws_vpc.vpc_id.id

  dynamic "ingress" {
    for_each = var.rdssql_ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [data.aws_vpc.vpc_id.cidr_block]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


## DB Subnet Group

resource "aws_db_subnet_group" "rdssqldb_subnet_group" {
  name       = var.rdssql_db_subnet_group_name
  subnet_ids = data.aws_subnet_ids.isolated_subnets_ids.ids
}

resource "aws_db_instance" "rdssqldb_instance" {
  allocated_storage    = 10
  db_name              = "diodb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = var.user_name
  password             = var.rdssql_password
  parameter_group_name = aws_db_parameter_group.rdssqldb_paramater_group.name
  db_subnet_group_name = aws_db_subnet_group.rdssqldb_subnet_group.name
  skip_final_snapshot  = true
  backup_window            = var.backup_windows_retention_maintenance[0]
  backup_retention_period  = var.backup_windows_retention_maintenance[1]
  maintenance_window       = var.backup_windows_retention_maintenance[2]
  vpc_security_group_ids = [aws_security_group.rdssql_ingress.id]
  availability_zone     = "ap-northeast-1a"
  auto_minor_version_upgrade = false
}


resource "aws_db_parameter_group" "rdssqldb_paramater_group" {
  name   = "dio-dev-db-pg"
  family = "mysql5.7"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

```


### Deploying with Terraform

Now comes the exciting part - deploying the infrastructure using Terraform. We create the necessary Terraform configuration files, define the resources, and leverage Terraform's AWS provider to provision the infrastructure in a reliable and automated manner.

I will add all the locals and variables in a separate file that I used while writing above terraform.

**locals.tf**

```
 
locals {
  internet = "0.0.0.0/0"

  managedpolicies_AmazonECSTaskExecutionRolePolicy = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]

  managedpolicies_AmazonECSTaskRolePolicy = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips_ipv4 = ["0.0.0.0/0"]
  all_ips_ipv6 = ["::/0"]
}

```


veriables.tf

```

## VPC CIDR BLOCK
variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The IPv4 CIDR block for the VPC"
}

## Private Subnet CIDR BLOCK
variable "private_subnets" {
  type = map(number)
  default = {
    "ap-northeast-1a" = 1
    "ap-northeast-1c" = 2
  }
  description = "Map of AZ to a number that should be used for private subnets"
}

## Public Subnet CIDR BLOCK
variable "public_subnets" {
  type = map(number)
  default = {
    "ap-northeast-1a" = 3
    "ap-northeast-1c" = 4
  }
  description = "Map of AZ to a number that should be used for public subnets"
}


## for RDS

## isolated Subnet CIDR BLOCK
variable "isolated_subnets" {
  type = map(number)
  default = {
    "ap-northeast-1a" = 5
    "ap-northeast-1c" = 6
  }
  description = "Map of AZ to a number that should be used for public subnets"
}

## Security Group
variable "rdssql_db_subnet_group_name" {
  type        = string
  default     = "dio-dev-db-subnet"
  description = "Name for the DB subnet group"
}


variable "rdssql_ingress_name" {
  type        = string
  default     = "dio-dev-db-sg"
  description = "Security Group name"
}

variable "rdssql_ingress_ports" {
  type        = list(number)
  default     = [3306]
  description = "List of ports opened from Private Subnets CIDR to RDS SQL Instance"
}



variable "rdssql_password" {
  type        = string
  default     = "MyStrongPa$w0rd"
  description = "RDS Admin password"
  sensitive   = true
  ## Terraform _ Sensitive Variables = https://learn.hashicorp.com/tutorials/terraform/sensitive_variables
}



variable "backup_windows_retention_maintenance" {
  type        = list(any)
  default     = ["03:00-06:00", "35", "Mon:00:00-Mon:03:00"]
  description = "Backup window time, desired retention in days, maitenance windows"
}

variable "rds_db_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "Amazon RDS DB Instance class"
  # Instance type: https://aws.amazon.com/rds/sqlserver/instance_types/
}

variable "storage_allocation" {
  type        = list(any)
  default     = ["20", "100"]
  description = "Allocated storage Gb, Max allocated storage Gb"
}

variable "user_name" {
  type        = string
  default     = "dioadmin"
  description = "mySQL Admin username"
}

## ECS Cluster

variable "ecs_cluster_name" {
  type    = string
  default = "dio-dev-ecs-cluster"
}


variable "ecs_container_name"{
  type    = string
  default = "dio-container"  
}
## ECS IAM Roles and Instance Roles

variable "ecsTaskExecutionRole_name" {
  type    = string
  default = "dio-dev-task-exec-role"
}

variable "ecsTaskRole_name" {
  type    = string
  default = "dio-dev-task-role"
}

variable "alb_ingress_name" {
  type    = string
  default = "dio-ecs-cluster-sg"
}

variable "ecs_fargate_task_name" {
  type    = string
  default = "dio-dev-task"
}

variable "alb_ingress_ports" {
  type        = list(number)
  description = "List of ports opened from Internet to ALB"
  default     = [80]
}

## ECS Task Definitions

### Fargate Task_Definition

variable "fargate_task_definition_name" {
  type    = string
  default = "dio-dev-td"
}

variable "fargate_task_definition_cpu" {
  type    = number
  default = "1024"
}

variable "fargate_task_definition_memory" {
  type    = number
  default = "2048"
}

variable "fargate_task_definition_image" {
  type    = string
  default = "httpd:latest"
}

## ECS Service

variable "ecs_service_name" {
  type    = string
  default = "dio-dev-ecs-service"
}

variable "desired_task_count" {
  type    = number
  default = "1"
}

## ALB

variable "alb_name" {
  type    = string
  default = "dio-dev-ecs-alb"
}

## ALB Target Group

variable "alb_target_group_name" {
  type        = string
  default     = "dio-dev-ecs-tg"
}

```


### Testing if its properly deployed:

We can follow the bellow link to verify the connection : https://repost.aws/knowledge-center/ecs-fargate-task-database-connection

also for troubleshooting we can use below cli command to access fargate interactively for mac you can install ssm plugin using bellow command

`brew install --cask session-manager-plugin`

To start the Fargate session, the following command can be used

`aws ecs execute-command --cluster arn:aws:ecs:ap-northeast-1:xxxxxxxxxx:cluster/ECS-xxxxxx --task arn:aws:ecs:ap-northeast-1:xxxxxxxxx:task/ECS-xxxxxxxxx/d0xxxxxxxxxxxxxxxx --container appache_xxxxxxx --interactive --command "/bin/sh" --region ap-northeast-1`

### Conclusion

In this article, we explored the process of building and configuring Fargate with RDS using Terraform. We discussed the benefits of using Terraform for Infrastructure as Code, outlined the prerequisites, and covered the key steps involved in setting up the environment, creating the Fargate task definition, configuring the RDS database instance, and handling networking and security considerations. By leveraging Terraform's power, developers can streamline the deployment and management of their containerized applications, ensuring scalability, reliability, and ease of maintenance.

With this knowledge, you are now equipped to embark on your journey of building and configuring Fargate with RDS using Terraform. Happy coding and deploying!

\[Disclaimer: Ensure that you follow best practices and security considerations while deploying and managing your infrastructure. The code examples provided in this article are for illustrative purposes only and may require customization based on your specific requirements and environment.\]