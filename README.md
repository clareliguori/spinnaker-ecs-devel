# Set up a Spinnaker ECS plugin development environment

## Install Spinnaker On a Dev Instance (Ubuntu)

Ubuntu 18.04, m5.4xlarge

hal config storage s3 edit --access-key-id AKIAXXXXXXXXXX --secret-access-key --region us-west-2

hal config storage edit --type s3

hal config version edit --version 1.8.5

hal config provider aws account add my-aws-devel-acct --account-id 123456789012 --assume-role role/Spinnaker-QuickStart-SpinnakerRole-D23QARZS58KU

hal config provider aws account edit my-aws-devel-acct --regions eu-central-1

hal config provider aws enable

hal config provider ecs account add ecs-my-aws-devel-acct --aws-account my-aws-devel-acct

hal config provider ecs enable

hal config deploy edit --type localgit --git-origin-user=clareliguori

hal config version edit --version branch:upstream/master

sudo hal deploy apply

Launch CFN template for VPC
       aws cloudformation deploy --template-file spinnaker-vpc.yml --region eu-central-1 --stack-name SpinnakerVPC

## Configure registries

hal config provider docker-registry enable

hal config provider docker-registry account add dockerhub-clareliguori --address index.docker.io --repositories clareliguori/my-image-repo --username clareliguori --password --track-digests true

hal deploy apply

## Connect to Spinnaker

ssh -A -L 9000:localhost:9000 -L 8084:localhost:8084 -L 8087:localhost:8087 ubuntu@$SPINNAKER_INSTANCE

rsync --progress -a /home/local/ANT/liguori/code/spinnaker/ ubuntu@$SPINNAKER_INSTANCE:/home/ubuntu/dev/spinnaker

ssh $SPINNAKER_INSTANCE 'for i in ~/dev/spinnaker/*; do (cd $i && echo $i && git checkout master && git clean -fdx); done'

