# Sample application

After setting up a Spinnaker development environment and a deployment region, create the infrastructure (LBs, security groups, etc) for a new ECS service.  In this example, the deployment region is eu-central-1.

```aws cloudformation deploy --template-file spinnaker-deployment-lb.yml --region eu-central-1 --stack-name spinnaker-ecs-demo```

Push some sample images to the ECR repository:

```
$(aws ecr get-login --no-include-email --region eu-central-1)

docker pull nginxdemos/hello

docker tag nginxdemos/hello 123456789012.dkr.ecr.eu-central-1.amazonaws.com/spinnaker-deployment-images:nginx

docker push 123456789012.dkr.ecr.eu-central-1.amazonaws.com/spinnaker-deployment-images:nginx

docker pull daviey/nyan-cat-web

docker tag daviey/nyan-cat-web 123456789012.dkr.ecr.eu-central-1.amazonaws.com/spinnaker-deployment-images:nyancat

docker push 123456789012.dkr.ecr.eu-central-1.amazonaws.com/spinnaker-deployment-images:nyancat
```

Go to http://localhost:9000/#/applications/aws/executions and create a new pipeline named "ecs-demo".  Go to Pipeline Actions -> Edit as JSON, and paste in the contents of sample-pipeline.json.  Click Save Changes.

Go back to the Executions page, and click "Start Manual Execution".  Choose one of the tags to deploy.

When the deployment completes, load the webpage:

```aws cloudformation describe-stacks --region eu-central-1 --stack-name spinnaker-ecs-demo --query 'Stacks[0].Outputs[0].OutputValue' --output text```