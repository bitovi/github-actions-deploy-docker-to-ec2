
## Introducing 

### Get the code! (Using bitops_code_only and bitops_code_store)
This allow the code to be generated (not executed) and stored as an artifact as a result in your action, allowing you to download and check anything. Keep in mind this code runs in a Bitops container. (More [here](http://bitops.sh))

### Code welcome! 
Add your own Terraform and Ansible oode (using `gh_deployment_*` variables). - We open the possibility to add some Terraform and Ansible code in. Useful only for super-advanced users. 

### TF_STATE handling improvements!
tf_state filename handling (added `tf_state_file_name` and `tf_state_file_name_append`) This allows you to handle the tf_state filename, so if you want to store all of your states in one bucket, you can handle that here. 

### Cloudwatch for docker - Get your docker logs into AWS Cloudwatch!
No more need to go into the instance. You'll see 4 variables for this in the docker section.

### VPC Handling - Use default, create one or reuse an existing one, up to you!
Whole section below!

### ELB, EC2 and APP Ports - Need more than one? worry not. 
Add as many as you want, separating them with a coma. For the ELB, will be mapping one to one (`aws_elb_listen_port` <-> `aws_elb_app_port`) based on the minimum length of those.

### Domain and certs 
Domain handling and certificate handlings defaults changed. You should enable `aws_r53_enable` and `aws_r53_enable_cert`.

### AWS_EFS received a revamp
Some variable names have changed (Detailed below)

### DATABASES! 
We baked in RDS with optional proxy and removed Aurora. (If you still want Aurora, an action will be created later for it. Check us in the [GH Marketplace](https://github.com/marketplace?query=bitovi&type=actions&verification=verified_creator))

### TAG EVERYTHING!
You'll find that after each main section there's a variable allowing you to add tags to those resources. Anything there will be ADDED to the default tags!

## Gone variables
- aws_efs_zone_mapping
- aws_mount_efs_security_group_id

## BREAKING CHANGES
1. AWS Postgres was renamed to RDS.
2. Lots of variable names changed completely for standarization purposes. 

## NON-BREAKING CHANGES
- ELB Healtcheck: Instead of `HTTP:app_port` now is static to `TCP:22`.
- EC2 Instance will only have the port 22 open. Any port defined in `aws_elb_app_port` and `aws_elb_listen_port` will apply to the ELB. See `aws_ec2_port_list` to open instance ports. 