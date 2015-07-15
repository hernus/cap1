set :user, "vagrant"

server '192.168.33.10',
user: 'vagrant',
roles: %w{web app db},
ssh_options: {
  user: 'vagrant', 
  # keys: ['~/.vagrant.d/insecure_private_key'],
  # forward_agent: true,
  # auth_methods: %w(publickey password)
  password: 'vagrant'
}