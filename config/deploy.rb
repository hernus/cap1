# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'my_app_name'
set :repo_url, 'https://github.com/hernus/cap1.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
 set :deploy_to, '/sites/cap1'
 deploy_user = 'vagrant'
 chef_repo = "https://github.com/hernus/chef_for_romeo_v1.git"


# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'precompile:assets'
      # end
    end
  end

  task :assets_precompile do
    on roles(:web) do
      within release_path do
        execute :rake, "assets:precompile RAILS_ENV=production"
      end
    end
  end

  after :publishing, 'deploy:assets_precompile'

end


# --------------------------------------------------------------------

namespace :provision do

   ruby_v = "ruby-2.0.0-p247"
   rvm_env = {
     'PATH' => "/usr/local/rvm/gems/#{ruby_v}/bin:/usr/local/rvm/rubies/#{ruby_v}/bin:/usr/local/rvm/bin:$PATH",
     'RUBY_VERSION' => ruby_v, 
     'GEM_HOME'     => "/usr/local/rvm/gems/#{ruby_v}",
     'GEM_PATH'     => "/usr/local/rvm/gems/#{ruby_v}",
     'BUNDLE_PATH'  => "/usr/local/rvm/gems/#{ruby_v}"
   }

   # set :pty, true

   task :create_site_directory do
      on roles(:web) do |host|
         execute "cd / && sudo mkdir sites && sudo chown #{deploy_user} sites"
      end
   end

   task :install_rvm do
      on roles(:web) do |host|
          execute  "sudo apt-get update"
          execute  "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3"
          execute  '\curl -sSL https://get.rvm.io | sudo bash -s stable'
          execute  'sudo adduser vagrant rvm' 
          execute  "sudo", "/usr/local/rvm/bin/rvm install #{ruby_v}"
          execute  "sudo /usr/local/rvm/bin/rvm alias create default #{ruby_v}"
      end
   end


   set :default_env, rvm_env
   task :install_chef do
      on roles(:web) do |host|
        # execute  'sudo', '/usr/local/rvm/bin/rvm all do gem install bundler --no-rdoc --no-ri'
        # execute  'sudo', '/usr/local/rvm/bin/rvm all do gem install chef --no-rdoc --no-ri'

        # execute  'sudo', 'apt-get install git -y'
        execute  'cd /sites && mkdir chef'
      end
   end


   set :default_env, rvm_env
   task :chef_execute do
      on roles(:web) do |host|
          within "/sites/chef" do
             execute  :git, :pull
             execute  :sudo , "chef-solo",  '-c solo.rb -j node.json'       
          end
      end
   end


   # set :default_env, rvm_env
   # task :prepare_app do
   #    on roles(:web) do |host|
   #       within "/vagrant" do
   #          execute  :bundle, "install"
   #          execute  :rake,   "db:create"
   #          execute  :rake,   "db:schema:load"
   #       end
   #    end
   # end

end

task :provision do
   # invoke 'provision:create_site_directory'
   # invoke 'provision:install_rvm'
   # invoke 'provision:install_chef'
   invoke 'provision:chef_execute'
end


