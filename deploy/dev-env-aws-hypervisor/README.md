# EC2 Deploy Scripts
These make targets will help you setup and configure an EC2 instance for development purposes.
First, the environment of the deployment host will be setup. Then, a CloudFormation stack will be created to provide an accessible EC2 instance. 

## 1. Environment Setup
### AWS CLI
You will need to have the AWS CLI Configured and the `AWS_PROFILE` environment variable configured.

For getting and configuring the CLI: https://docs.aws.amazon.com/cli/

You can check if you have the AWS CLI properly configured by running the following:

```bash
$ aws configure list
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile            openshift-dev              env    ['AWS_PROFILE', 'AWS_DEFAULT_PROFILE']
access_key     ****************4SU3 shared-credentials-file    
secret_key     ****************z0DF shared-credentials-file    
    region                us-east-2      config-file    ~/.aws/config
```
### Dependencies
The following programs must be present in your local environment
- make
- aws
- jq
- rsync
- golang

Also:
- .ssh/config file must exist

#### Extra dependencies
For automatic Redfish Pacemaker configuration on 4.19, you also need:
- Python3 kubernetes library (https://pypi.org/project/kubernetes/)

Additionally, if you're using Mac OS, you might not have `timeout`, so you might also need to install coreutils, for example via brew:
`brew install coreutils`

### Preparing the instance.env
The `instance.env.template` file has all of the required variables for the EC2 deployment, initialization, and connection. Copy the `instance.env.template` file to `instance.env` and set all the variables to the valid values for your user.

### Verifying your environment
To verify your environment is setup properly, try sourcing the instance.env and ensure it doesn't throw errors.
```bash
source ./instance.env
```

## 2. Instance Deployment

### Running the Makefile
The Makefile is set to deploy the instance and the init function will copy over your dependencies before ssh-ing into the target machine.
This will place you in a login shell for the EC2 instance.
```bash
# Deploy an EC2 instance and initialize it
$ make deploy init
```
### Configuring the dev-environment
Once the instance is created and you're in the remote environment, initialize it by running the `configure.sh` file in the home directory.
```bash
[ec2-user@ip-x-x-x-x ~]$ ./configure.sh
```
You will be asked to: 
   - Set a password for pitadmin (cockpit access)
   - Register the system using your RHSM login, for dnf access to various repositories.

### Utility commands
Now that initialization is complete, here are some other utility commands provided for interacting with your AWS dev environment. These are run from the deployment host.

```bash
# SSH into the EC2 instance
$ make ssh

# Get instance info
$ make info

# Cleanup the deployment
$ make destroy
```