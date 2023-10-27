
## Introducing 

### Get the code! (Using bitops_code_only and bitops_code_store)
This allow the code to be generated (not executed) and stored as an artifact as a result in your action, allowing you to download and check anything. Keep in mind this code runs in a Bitops container. (More [here](http://bitops.sh))

### Code welcome! 
Add your own Terraform and Ansible oode (using gh_deployment_* variables). - We open the possibility to add some Terraform and Ansible code in. Useful only for super-advanced users. 

### TF_STATE handling improvements!
tf_state filename handling (added tf_state_file_name and tf_state_file_name_append) This allows you to handle the tf_state filename, so if you want to store all of your states in one bucket, you can handle that here. 

### Cloudwatch for docker - Get your docker logs into AWS Cloudwatch!
No more need to go into the instance. You'll see 4 variables for this in the docker section.

### VPC Handling - Use default, create one or reuse an existing one, up to you!
Whole section below!

### ELB, EC2 and APP Ports - Need more than one? worry not. 
Add as many as you want, separating them with a coma. For the ELB, will be mapping one to one (aws_elb_listen_port <-> aws_elb_app_port) based on the minimum length of those.

### AWS_EFS received a revamp
Some variable names have changed (Detailed below)

### DATABASES! 
Now we allow RDS and Aurora DB’s to be created, and with a proxy too! The whole section changed.

### TAG EVERYTHING!
You'll find that after each main section there's a variable allowing you to add tags to those resources. Anything there will be ADDED to the default tags!

## Small details added, but maybe not that small.
- lb_create - Add toggle to allow disabling the ELB
- ansible_skip - Skips ansible execution after terraform finishes.
- ansible_ssh_to_private_ip - If using self hosted runner, will connect to the private IP of the EC2 instance.
- ec2_ami_update - Update the ami to the latest image if a new one exists. Will destroy and recreate the instance if so. (And the data with it)
- ec2_root_preserve - Keeps the root volume after deletion.
- ec2_instance_public_ip - In some cases, you don’t need the instance to have a public IP. 
- ec2_port_list - Ports to be opened just in the EC2 SG. (Port 22 is enabled as default) - Traffic from the ELB SG to the EC2 SG is automatically allowed.
- ec2_user_data_file - Allows adding a shell script to be executed when instance spins up.
- ec2_user_data_replace_on_change - That. If the user_data file changes, will stop and start the instance. (As it runs after start)

## Variable renaming happened. Sorry. 
| OLD | NEW |
|----------------------|----------------------|
| additional_tags | aws_additional_tags |
| targets | tf_targets |
| aws_ami_id | ec2_ami_id |
| aws_create_efs | aws_efs_create |
| aws_create_ha_efs | aws_efs_create_ha |
| aws_create_efs_replica | aws_efs_create_replica |
| aws_enable_efs_backup_policy | aws_efs_enable_backup_policy |
| efs_mount_target | aws_efs_mount_target |
| data_mount_target | docker_efs_mount_target |
| aws_replication_configuration_destination | aws_efs_replication_destination |
| aws_mount_efs_id | aws_efs_fs_id |
| no_cert | enable_cert |
<br/>

## Gone variables
- aws_efs_zone_mapping
- aws_mount_efs_security_group_id

## BREAKING CHANGES
1. AWS RDS was renamed to Aurora, as we support both Postgres or MySQL engines.
2. EFS variable names changed completely for standarization purposes. 

## NON-BREAKING CHANGES
- ELB Healtcheck: Instead of `HTTP:app_port` now is static to `TCP:22`.
- EC2 Instance will only have the port 22 open. Any port defined in `app_port` and `lb_port` will apply to the ELB. See `ec2_port_list` to open instance ports. 