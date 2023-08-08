# energy-project-dashboard

This dashboard is responsible for tracking and managing a company's renewable energy projects. The application consists of 2 microservices:

* Project Service: Manages information about renewable energy projects. Responsible for project creation, updates, retrieval, and handles information such as project name, location, and status.

* Data Service: Gathers, analyzes and visualizes data. Calculates energy generation and consumption, tracks project finances such as expenses and revenue, and alerts stakeholders when milestones are reached.

## Infrastructure Diagram

[Lucidchart Diagram](https://lucid.app/lucidchart/d7b5cec3-4a6b-4558-b598-36adabf8136d/edit?viewport_loc=-1439%2C-802%2C2600%2C1275%2C0_0&invitationId=inv_d858574f-5449-4818-b34b-836710971e54)

![Diagram](<Energy Project Dashboard Infrastructure.jpeg>)

## Terraform Infrastructure

Terraform provisions the AWS resources presented in the infrastructure diagram. When the Terraform code in this repository is executed with `terraform init` and `terraform apply`, the configuration files direct the AWS API to create or update resources in AWS.

## Process Flow

1. User DNS queries are processed through Amazon Route 53 Resolver. The Amazon Route 53 Resolver can be configured with various firewall settings to inspect and block certain DNS queries.

1. Amazon CloudWatch provices continuous monitoring.

1. The AWS resources are distributed across multiple Availability Zones in order to improve fault tolerance.

1. Amazon resources are hosted in a Virtual Private Cloud (VPC). The Internet Gateway allows for communications between the VPC and the Internet.

1. The user's request to access the dashboard goes through the Application Load Balancer (ALB). The ALB distributes incoming traffic across multiple targets, in this case containers in separate subnets in multiple Availability Zones. The ALB automatically scales depending on the size of the workload.

1. The ALB forwards the request to one of the Elastic Container Service (ECS) instances.

1. The Project and Notification services all run on Docker containers. These Docker containers are configured and stored in the Elastic Container Registry (ECR), and are orchestrated ECS.

1. Data from each of the microservices is collected in respective Amazon relational databases (RDS) distributed in separate subnets and Availability Zones.

1. Security Groups control traffic to resources in the VPC.

1. Developers may update the Docker images in ECR using AWS CodePipeline, CodeCommit, and CodeBuild in order to ensure continuous testing and deployment.

## Fault Tolerance

The architecture achieves fault tolerance through redundancy and load balancing:

1. **Redundancy**: Multiple instances of microservices are run using Amazon ECS. If one instance fails, others continue serving traffic.

1. **Load Balancing**: The ALB distributes traffic across instances. If one fails, the ALB routes traffic to healthy ones.

1. **Multiple Availability Zones**: Deploying across multiple availability zones enhances fault tolerance. If one zone fails, others maintain service.

These measures help ensure the architecture remains highly available and resilient to failures.

## Scalability

The architecture is designed for scalability:

1. **ECS Scalability**: Amazon ECS allows running multiple instances of microservices. As demand increases, more instances can be added to handle traffic spikes.

1. **Load Balancing**: The ALB evenly distributes traffic among instances. New instances can be added dynamically to accommodate increased load.

1. **Automatic Scaling**: ECS can automatically adjust the number of instances based on metrics like CPU usage or request rates, ensuring optimal performance.

1. **Infrastructure as Code**: Terraform allows easy replication of resources. New environments can be created quickly to scale.

This combination of ECS, load balancing, automatic scaling, multiple Availability Zones, and infrastructure as code ensures the architecture can seamlessly handle growing workloads while maintaining performance.

## Limitations

This setup would be improved by logically separating the complex processes. This would include creating separate environments for `development` and `production` as well as creating separate modules for the configuration of `vpc`, `ecs`, and `rds`.

This configuration is simplified and both `variables.tf` and `outputs.tf` are incomplete. In a real configuration, testing the provisioning of the Terraform resources would help inform variables and outputs to include. I would also configure Hashicorp Vault to handle access to AWS and manage credentials securely.
