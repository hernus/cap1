set :user, "vagrant"

server '192.168.33.10',
user: fetch(:user , "deploy"),
roles: %w{web app db},
ssh_options: {
  user: fetch(:user, "deploy"), 
  # keys: ['~/.vagrant.d/insecure_private_key'],
  # forward_agent: true,
  # auth_methods: %w(publickey password)
  password: 'vagrant'
}