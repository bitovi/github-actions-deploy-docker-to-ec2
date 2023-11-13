
# What's new? 

## Get the code! 
Using `bitops_code_only` and `bitops_code_store` makes all of the IaC code to be generated (not executed) and stored as an artifact in your workflow run, allowing you to download, check and do anything you need with it. Keep in mind this code runs in a Bitops container. (More [here](http://bitops.sh))

## TF_STATE handling improvements!
tf_state filename handling (added `tf_state_file_name` and `tf_state_file_name_append`) This allows you to handle the tf_state filename, so if you want to store all of your states in one bucket, you can handle that here.

Keep in mind that if you are doing multiple executions of our actions in the same workflow, `aws_resource_identifier`, that's used throughout the code, will not be unique. Hence change that to something significant in each step.

## Cloudwatch for docker - Get your docker logs into AWS Cloudwatch!
No more need to go into the instance. You'll see 4 variables for this in the docker section.

## VPC Handling - Use default, create one or reuse an existing one, up to you!
Whole section to create one, or use a specific one!

## ELB, EC2 and APP Ports - Need more than one? worry not. 
Add as many as you want, separating them with a comma. For the ELB, ports will be mapped one-to-one (`aws_elb_listen_port` <-> `aws_elb_app_port`). If length doesn't match, will expose the minimum ammount of matching pairs.

## Domain and certs 
Some domain and certificate defaults changed. You should toggle `aws_r53_enable` and `aws_r53_enable_cert` if you wish to use those.

## AWS EFS received a revamp
Lots of variable names have changed. Check the README section.

## RDS Database 
We replaced Aurora for RDS (with optional proxy) giving more options and flexibility for DB Creation.

## TAG EVERYTHING!
You'll find that after each main section there's a variable allowing you to add tags to those resources. Anything there will be ADDED to the default tags!

## Code welcome! 
Add your own Terraform and Ansible oode (using `gh_deployment_*` variables). - We open the possibility to add some Terraform and Ansible code in. Useful only for super-advanced users. 

# BREAKING CHANGES
As our action kept expanding, we needed to standardize the naming of variables to something that made more sense. So we ended up setting `<provider>_<resource>_<var_id>` as default, and with that, input names changed. </br>
We did our best to allow using the old variables with the new action by mapping them to the new ones and setting defaults in the action, but still, some behaviours changed, and some variables are gone (3).</br>
You can check the legacy inputs section in the action.yaml if you wish to get more details.</br>
And **Aurora** is now gone.

## NON-BREAKING CHANGES (but to keep in mind)
- ELB Healtcheck: Instead of `HTTP:app_port` now is static to `TCP:22`.
- EC2 Instance will **only** have the port `22` open. Any port defined in `aws_elb_app_port` and `aws_elb_listen_port` will apply to the ELB. This reduces the ammount of ports the EC2 instance expose publicly. See `aws_ec2_port_list` to open instance ports. 