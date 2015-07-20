# set :user, "vagrant"
set :user, "ubuntu"

# server '192.168.33.10',
server 'ec2-54-153-216-2.ap-southeast-2.compute.amazonaws.com',
user: fetch(:user , "deploy"),
roles: %w{web app db},
ssh_options: {
  user: fetch(:user, "deploy"), 
  # keys: ['~/.vagrant.d/insecure_private_key'],
    keys: ['/users/hernus/my_pem_files/romeo_aws.pem'],
    forward_agent: true
  # auth_methods: %w(publickey password)
  #  password: 'vagrant'
}