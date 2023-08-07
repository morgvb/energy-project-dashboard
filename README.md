# energy-project-dashboard

Basic Terraform configuration for an energy project dashboard consisting of 4 microservices: an application service, project service, financial service, and notification service.

## Terraform Infrastructure

Terraform provisions the AWS resources presented in the infrastructure diagram. When the Terraform code in this repository is executed, the configuration files direct the AWS API to create or update resources in AWS.

1. Run `terraform init` to initialize AWS provider.

1. Run `terraform plan` to add parameters.

1. Run `terraform apply` to apply the commands.

## Process Flow

1. User DNS queries are processed through Amazon Route 53 Resolver. The Amazon Route 53 Resolver can be configured with various firewall settings to inspect and block certain DNS queries.

1. Amazon CloudFront routes the user's request to the lowest latency edge location in order to deliver the User Interface.

1. AWS Certificate Manager provides SSL encryption for the website delivered by Amazon CloudFront.

1. Amazon CloudWatch provides continuous monitoring for the CloudFront distribution.

1. Amazon resources are hosted in a Virtual Private Cloud(VPC), which can be separated to improve fault tolerance.

1. The Internet Gateway allows for communications between the VPC and the Internet.

1. The user's request to access the dashboard goes through the Application Load Balancer (ALB). The ALB distributes incoming traffic across multiple targets, in this case containers in separate subnets in multiple Availability Zones. The ALB automatically scales depending on the size of the workload.

1. The Application, Project, Financial, and Notification services all run on Docker containers. These Docker containers are configured and stored in the Elastic Container Registry (ECR), and are orchestrated by the Elastic Kubernetes Service (EKS).

1. The Application Service communicates with the other microservices to retrieve and update data through event driven architecture and API calls.

1. Amazon EKS runs and scales the Kubernetes control plane across multiple AWS Availability Zones.

1. Data from each of the microservices is collected in separate Amazon relational databases.

1. Security Groups control traffic to resources in the VPC.

1. Developers may update the Docker images in ECR using AWS CodePipeline, CodeCommit, and CodeBuild in order to ensure continuous testing and deployment.

## Fault Tolerance

## Scalability
