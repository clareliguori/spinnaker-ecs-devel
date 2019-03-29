# Set up a Spinnaker ECS plugin development environment

In this setup, Spinnaker runs on an EC2 instance.  Code is edited on the laptop and then synced to the EC2 instance for testing.

<!-- toc -->

- [Laptop](#configure-laptop)
- [Deployment Region](#configure-deployment-region)
- [Development Region](#configure-development-region)
- [Development Instance](#configure-development-ec2-instance)
- [Test Changes](#test-spinnaker-code-changes)
- [Sync From Upstream](#regularly-sync-from-upstream)

<!-- tocstop -->

## Configure laptop

Create forks of all the Spinnaker microservices on GitHub:

https://www.spinnaker.io/reference/architecture/#spinnaker-microservices

Clone them onto your laptop:

```./clone.sh {your github user} ~/code/spinnaker```

Set up IntelliJ:

https://www.spinnaker.io/guides/developer/getting-set-up/#intellij

## Configure deployment region

Provision infrastructure in the region that will be available in Spinnaker to deploy ECS services.  This can be different from the region where your development instance will live.  For example, a Spinnaker instance running in us-west-2 can deploy to ECS services in eu-central-1.

Provision a deployment VPC, with the correct tags on the subnets that Spinnaker will recognize:

```aws cloudformation deploy --template-file spinnaker-deployment-vpc.yml --region eu-central-1 --stack-name SpinnakerVPC```

## Configure development region

Provision some roles for Spinnaker:

```aws cloudformation deploy --template-file spinnaker-roles.yml --region us-west-2 --stack-name SpinnakerRoles --capabilities CAPABILITY_NAMED_IAM```

In the default VPC, create a security group named "SpinnakerDev", allowing port 22 inbound for a restricted set of IPs (for example, corporate firewall ranges).  Then, provision a development instance:

```
key_pair_name="{ec2 key name}"

vpc_id=`aws ec2 describe-vpcs --region us-west-2 --filters Name=isDefault,Values=true --query 'Vpcs[0].VpcId' --output text`

subnet_id=`aws ec2 describe-subnets --region us-west-2 --filters "Name=vpc-id,Values=$vpc_id" "Name=default-for-az,Values=true" --query 'Subnets[0].SubnetId' --output text`

security_group_id=`aws ec2 describe-security-groups --region us-west-2 --filters "Name=vpc-id,Values=$vpc_id" "Name=group-name,Values=SpinnakerDev" --query 'SecurityGroups[0].GroupId' --output=text`

aws cloudformation deploy --template-file spinnaker-dev-instance.yml --region us-west-2 --stack-name SpinnakerDevInstance --parameter-overrides EC2KeyPairName=$key_pair_name SubnetId=$subnet_id SecurityGroupId=$security_group_id
```

## Configure development EC2 instance

Get your instance's DNS name and login via SSH:

```
spinnaker_instance=`aws cloudformation describe-stacks --region us-west-2 --stack-name SpinnakerDevInstance --query 'Stacks[0].Outputs[0].OutputValue' --output text`

ssh -A -L 9000:localhost:9000 -L 8084:localhost:8084 -L 8087:localhost:8087 ubuntu@$spinnaker_instance
```

Follow the GitHub instructions to [generate a new SSH key](https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) on the Spinnaker instance and [add it to your GitHub account](https://help.github.com/en/articles/adding-a-new-ssh-key-to-your-github-account).

Install dependencies:
```
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
source ~/.bashrc
nvm install stable
npm install -g yarn

curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
sudo bash InstallHalyard.sh
source ~/.bashrc
hal -v
```

Configure and deploy the Spinnaker installation:
```
# Store state in S3 and deploy a recent stable version
hal config storage s3 edit --region us-west-2
hal config storage edit --type s3
hal config version edit --version 1.13.0
sudo hal deploy apply

sudo service apache2 stop
sudo systemctl disable apache2

# Workaround: https://github.com/spinnaker/spinnaker/issues/4041
echo > ~/.hal/default/profiles/settings-local.js

# Clone repos from your GitHub account
hal config deploy edit --type localgit --git-origin-user={your github username}
hal config version edit --version branch:master

# Connect your AWS and ECS accounts
hal config provider aws account add my-aws-devel-acct \
    --account-id 123456789012 \
    --assume-role role/SpinnakerManaged
hal config provider aws account edit my-aws-devel-acct --regions eu-central-1
hal config provider aws enable

hal config provider ecs account add ecs-my-aws-devel-acct --aws-account my-aws-devel-acct
hal config provider ecs enable

# Connect your Docker registries
hal config provider docker-registry enable

hal config provider docker-registry account add my-dockerhub-devel-acct \
    --address index.docker.io \
    --repositories {your dockerhub username}/{your dockerhub repository} \
    --username {your dockerhub username} \
    --password \
    --track-digests true

hal config provider docker-registry account add my-eu-central-1-devel-registry \
 --address 012345678910.dkr.ecr.eu-central-1.amazonaws.com \
 --username AWS \
 --password-command "aws --region eu-central-1 ecr get-authorization-token --output text --query 'authorizationData[].authorizationToken' | base64 -d | sed 's/^AWS://'" \
 --track-digests true

# Deploy everything
hal deploy apply
```

Wait for Clouddriver to start up by checking the logs in ~/dev/spinnaker/logs/clouddriver.log.

You should now be able to reach the Spinnaker interface at http://localhost:9000.

## Test Spinnaker code changes

Retrieve the instance's DNS name:
```
spinnaker_instance=`aws cloudformation describe-stacks --region us-west-2 --stack-name SpinnakerDevInstance --query 'Stacks[0].Outputs[0].OutputValue' --output text`
```

Sync your changes to the development instance:
```
rsync --progress -a ~/code/spinnaker/ ubuntu@$spinnaker_instance:/home/ubuntu/dev/spinnaker

Optional:
ssh ubuntu@$spinnaker_instance 'for i in ~/dev/spinnaker/*; do (cd $i && echo $i && git checkout master && git clean -fdx); done'
```

Login to the instance, deploy the changes, and check for build or service failures:
```
ssh -A -L 9000:localhost:9000 -L 8084:localhost:8084 -L 8087:localhost:8087 ubuntu@$spinnaker_instance

hal deploy apply
(or for individual service changes: hal deploy apply --service-names=clouddriver,deck)

cd ~/dev/spinnaker/logs
```

Test your changes manually at http://localhost:9000.

## Regularly sync from upstream

Add the following to your laptop's .bashrc file
```
sync-from-upstream() {
    for i in ./*; do
        (cd $i && echo $i && git checkout master && git pull --rebase upstream master && git push origin upstream/master:master)
    done
}
```

Then regularly run `sync-from-upstream` in ~/code/spinnaker to keep your local repos and GitHub forks in sync with upstream Spinnaker.