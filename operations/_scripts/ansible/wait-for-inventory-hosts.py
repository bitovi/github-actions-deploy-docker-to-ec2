import yaml
import subprocess
import os

port = "22"
timeout = "60"
TEMPDIR = os.getenv('BITOPS_TEMPDIR')
ENVROOT = os.getenv('BITOPS_ENVROOT')

try:
    tf_inventory_path = "{}/terraform/inventory.yaml".format(ENVROOT)
    with open(tf_inventory_path,'r') as file:
        try:
            print("Running wait for host script:")
            inventory = yaml.safe_load(file)
            bitops_hosts = inventory["bitops_servers"]["hosts"]
            # Check for multiple bitops_hosts, if found wait for first host in list
            if isinstance(bitops_hosts, str):
                print("Waiting for host:", bitops_hosts)
            else:
                bitops_hosts = bitops_hosts[0]
                print("Waiting for host:", bitops_hosts)      
            wait_for_command = "{}/_scripts/ansible/wait-for-it.sh -h {} -p {} -t {}".format(TEMPDIR,bitops_hosts,port,timeout)
            result = subprocess.call(wait_for_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        except yaml.YAMLError as exception:
            print(exception)
except IOError:
    print("Terraform inventory file not found. Skipping wait for hosts.")
