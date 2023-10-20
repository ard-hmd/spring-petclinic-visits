# spring-petclinic-visits

This repo is used for the **spring-petclinic-cloud-visits-service**.

This repo is meant to:
1. build the Docker image of the app and push it a DockerHub registry
2. deploy the Docker container on a EKS cluster using Helm charts


## Build
This repo is meant to be built with CodeBuild.
The [petclinic-visits-build](https://eu-west-3.console.aws.amazon.com/codesuite/codebuild/296615500438/projects/petclinic-visits-build/history?region=eu-west-3) CodeBuild project is deployed using [Terraform](https://github.com/ard-hmd/spring-petclinic-custom/tree/iac/pipelines/iac/pipelines).
The build phases are described in _buildspec.yml_.

### Start/stop a build
Following the URL [petclinic-visits-build](https://eu-west-3.console.aws.amazon.com/codesuite/codebuild/296615500438/projects/petclinic-visits-build/history?region=eu-west-3) will display the AWS console on the CodeBuild project.
From there, it's possible to either

### Codebuild Environment
- Environment image: `aws/codebuild/amazonlinux2-x86_64-standard:corretto11-23.07.28`
- Service role: `arn:aws:iam::296615500438:role/petclinic-build-role` (created with [Terraform]([Terraform](https://github.com/ard-hmd/spring-petclinic-custom/tree/iac/pipelines/iac/pipelines)))
- Privileged mode: to have elevated rights for building Docker images

### buildspec.yml
There are 4 main sections. 1 section for setting environment (variables, secrets, etc) + 3 build phases.
1. Environment: (Optional) Defines the environment variables (see Environment section)
2. install: installs the requirements for build the app. It does so with the following script:
   - `scripts/setup_k8s_build.sh`: installs the required package to build the app, `java`, `maven`, `git`
4. pre_build: connects to the Docker repository
5. build: builds the app using `maven`
6. post_build: pushes the Docker image to the Docker repository

#### Environment
Currently, the environment variables are carried by the [petclinic-visits-build](https://eu-west-3.console.aws.amazon.com/codesuite/codebuild/296615500438/projects/petclinic-visits-build/history?region=eu-west-3) CodeBuild project.

ALthough it's possible to override the variables directly from the console, it is also possible to achieve the same objective by adding the following lines before the _phases_ section in the _buildspec.yml_ file.

```
env:
  variables: # plain text variables
    REPOSITORY_PREFIX: <DOCKER_IMAGE_REPOSITORY> # currently: michelnguyenfr

  parameter-store: # variables available in the [AWS parameter store](https://eu-north-1.console.aws.amazon.com/systems-manager/parameters?region=eu-west-3#)
    DOCKER_LOGIN: <DOCKER_REPO_LOGIN> # currently stored in the variable _PETCLINIC_DOCKER_PASSWORD_ of the Parameter Store)
    DOCKER_PASSWORD: <DOCKER_REPO_PASSWORD> # currently stored in the variable _PETCLINIC_DOCKER_PASSWORD_ of the Parameter Store)
```

Note that your IAM user needs to have the permissions to access the Parameter Store.

## Deployment
This repo can be deployed either manually


> [!WARNING]
> Neither of the deployment modes have been tested yet.

> [!NOTE]
> The CodeBuild project has not been built with Terraform yet.

### Requirements
To deploy manually the Helm chart, there are some requirements to setup:
- a running RDS instance
- a running EKS cluster

Before deploying, 
- Update value of SPRING_DATASOURCE_URL in `templates/visits-service-deployment.yaml`:
```
- name: SPRING_DATASOURCE_URL
          value: jdbc:mysql://visitsdb.c6wqjjevzbkj.eu-west-3.rds.amazonaws.com:3306/service_instance_db?queryInterceptors=brave.mysql8.TracingQueryInterceptor&exceptionInterceptors=brave.mysql8.TracingExceptionInterceptor&zipkinServiceName=visits-db
```

If not done already, provide your Access Key and Secret Access Key with `aws configure`:
```
aws configure
```
```
AWS Access Key ID [None]: <ACCESS_KEY> # your AWS access key
AWS Secret Access Key [None]: <ACCESS_SECRET_ACCESS_KEY> # your AWS secret access key
Default region name [None]: eu-west-3 # AWS region where the EKS cluster is hosted
Default output format [None]: json
```

- Update to the kube config to point the correct EKS cluster:
```
export CLUSTER_NAME=<EKS_CLUSTER_NAME> # name of the EKS cluster
export REGION=<AWS_REGION> # AWS region where the EKS cluster is hosted (eu-west-3)
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
```

- Define the environment to use. Possibles values are "dev", "qa", "prod".
```
export ENVIRONMENT= <ENVIRONMENT> # environment to use for the deployment
```

### Helm chart
To deploy the Helm chart, run the command:
```
helm upgrade spring-visits --install --values helm_values/values-${ENVIRONMENT}.yaml -n $ENVIRONMENT
```

When deploying a chart, 2 objects will be deployed:
1. a Kubernetes pod for _spring-petclinic-cloud-visits-service_
2. a Kubernetes service _spring-petclinic-cloud-visits-service-service_


### Helm values
There are 3 files for 3 enviroments: `dev`, `qa`, `prod`.
They define the value of the namespace to be used to deploy the Kubernetes objects.

