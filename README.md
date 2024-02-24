<p align="center">
    <h1 align="center">PROJECT4.0_INFRA</h1>
</p>
<p align="center">
	<!-- default option, no dependency badges. -->
</p>
<hr>

## Quick Links

> - [ Overview](#-overview)
> - [ Features](#-features)
> - [ Repository Structure](#-repository-structure)
> - [ Getting Started](#-getting-started)
>   - [ Installation](#-installation)
>   - [ Running project4.0_infra](#-running-project4.0_infra)
>   - [ Tests](#-tests)
> - [ Acknowledgments](#-acknowledgments)

---

## Barometer Axxes

## Overview

This project is designed to provision and manage infrastructure on AWS using Terraform and aims to simplify the process of deploying and maintaining your infrastructure as code.

---

## Features

- Infrastructure as Code (IaC): Define and manage your infrastructure using declarative configuration files.

- Modular Design: The project is organized into modular components for easy customization and maintenance.

- Version Control: Keep track of changes to your infrastructure by storing Terraform configurations in version control.

- Scalability: Easily scale your infrastructure up or down to meet changing requirements.

- Cloud Agnostic: This project can be deployed in any AWS environment without additional configuration.

- Pipeline: Automatic deployment on code pushes to production.

---

## Repository Structure

```sh
└── project4.0_infra/
    ├── .gitlab-ci.yml
    └── infrastructure
        ├── acm.tf
        ├── alb.tf
        ├── backend.tf
        ├── check_dns.sh
        ├── cloudflare.tf
        ├── cloudwatch.tf
        ├── data.tf
        ├── database.tf
        ├── ecs_api.tf
        ├── ecs_api_ai.tf
        ├── ecs_frontend.tf
        ├── get_private_ip.sh
        ├── security_groups.tf
        ├── sns.tf
        ├── terraform.tf
        └── vpc.tf
```

---

## Modules

<details closed><summary>Infrastructure</summary>

| File                                                                                                                                                            | Summary                                                                                     |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| [acm.tf](https://gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_infra/-/blob/main/infrastructure/acm.tf)                         | Configuration of resources for DNS certificate usage & management.                          |
| [alb.tf](https://gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_infra/-/blob/main/infrastructure/alb.tf)                         | Configuration of application load balancer for frontend.                                    |
| [backend.tf](https://gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_infra/-/blob/main/infrastructure/backend.tf)                 | Configuration for saving the Terraform statefile remotely.                                  |
| [cloudflare.tf](https://gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_infra/-/blob/main/infrastructure/cloudflare.tf)           | Configuration of Cloudflare resources required to use an external Cloudflare domain.        |
| [cloudwatch.tf](https://gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_infra/-/blob/main/infrastructure/cloudwatch.tf)           | Configuration of CloudWatch resources for ECS cluster monitoring.                           |
| [data.tf](https://gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_infra/-/blob/main/infrastructure/data.tf)                       | Data resources to extract credentials/data from the AWS environment.                        |
| [database.tf](https://gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_infra/-/blob/main/infrastructure/database.tf)               | Configuration of AWS database resources.                                                    |
| [ecs_api.tf](https://gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_infra/-/blob/main/infrastructure/ecs_api.tf)                 | Configuration of ECS resources to run the backend API container.                            |
| [ecs_api_ai.tf](https://gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_infra/-/blob/main/infrastructure/ecs_api_ai.tf)           | Configuration for ECS instances that run the AI containers (APP/API)                        |
| [ecs_frontend.tf](https://gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_infra/-/blob/main/infrastructure/ecs_frontend.tf)       | Configuration for ECS instances that run the frontend application code.                     |
| [security_groups.tf](https://gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_infra/-/blob/main/infrastructure/security_groups.tf) | Configuration of security groups.                                                           |
| [sns.tf](https://gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_infra/-/blob/main/infrastructure/sns.tf)                         | Configuration of email notifications in case of system failures.                            |
| [terraform.tf](https://gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_infra/-/blob/main/infrastructure/terraform.tf)             | Provider & Terraform version configuration.                                                 |
| [vpc.tf](https://gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_infra/-/blob/main/infrastructure/vpc.tf)                         | Configuration of AWS Virtual Private Cloud resources, like NAT Gateways, Route Tables, etc. |

</details>

<details closed><summary>Scripts</summary>

| File                                                                                                                                                          | Summary                                                             |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| [get_private_ip.sh](https://gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_infra/-/blob/main/infrastructure/get_private_ip.sh) | Script to fetch private ip address of API container.                |
| [check_dns.sh](https://gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_infra/-/blob/main/infrastructure/check_dns.sh)           | CloudFlare script to check if DNS records already exist yet or not. |

</details>

---

## Getting Started

**_Requirements_**

If you want to run this project **locally**, ensure you have the following dependencies installed on your system:

- **Terraform**: `version 1.6.1`

Within the Cloud Environment, you need to configure some credentials in the AWS Credentials Manager:

- Cloudflare Credentials
- GitLab Deploy Token
- SNS Email Secret
- Database Credentials (OR automatically generated ones)

**!! Important Information !!**

If you don't want to work locally, this project repository has a built-in pipeline which will set up the entire environment for you. Configuration can be found in the gitlab-ci.yml file. A pipeline can be started by commiting to the **main branch**, or by manually starting a pipeline in Build > Pipeline.

### Pipeline

**Stages**

- check_credentials: verify if the AWS credentials are valid, if not, the pipeline stops.
- validate: checks if the terraform code is valid.
- plan: generates an execution plan of the resources that need to be deployed, and saves it to a plan file.
- apply: applies the infrastructure plan to the cloud environment.
- destroy: destroys all resources except for the database to preserve production data.
- destroy_all: destroys all resources.

The following steps are only necessary when working locally.

### LOCAL Installation

1. Clone the project4.0_infra repository:

```sh
git clone https://gitlab.com/it-factory-thomas-more/cloud-engineering/23-24/r0889345/project4.0_infra
```

2. Change to the project directory:

```sh
cd project4.0_infra
```

3. Install the dependencies:

```sh
terraform init
```

### Running project4.0_infra LOCALLY

Use the following command to run project4.0_infra:

```sh
terraform apply
```

###

### Tests

To execute tests, run:

```sh
Insert test command.
```

---

## Acknowledgments

This project was made by Team J3.

Members:

- Caro Daems (CCS)
- Lars Kammeijer (CCS)
- Ingrid Hansen (AI)
- Murrel Venlo (APP)
- Elias Grinwis Plaat Stultjes (APP)
- Thomas Malecki (APP)

[**Return**](#-quick-links)

---
