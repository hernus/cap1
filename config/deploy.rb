# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'cap1'
set :repo_url, 'https://github.com/hernus/cap1.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
 set :deploy_to, '/sites/cap1'
 deploy_user = 'ubuntu'
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

  # after :restart, :clear_cache do
  #   on roles(:web), in: :groups, limit: 3, wait: 10 do
  #     # Here we can do anything such as:
  #     # within release_path do
  #     #   execute :rake, 'precompile:assets'
  #     # end
  #   end
  # end

  task :assets_precompile do
    on roles(:web) do
      within release_path do
        execute :rake, "assets:precompile RAILS_ENV=production"
      end
    end
  end

  task :site_symlink do
    on roles(:web) do
      if remote_path_exists?("/etc/nginx/sites-enabled/default") 
        execute :sudo, :rm, "/etc/nginx/sites-enabled/default"
      end
      unless remote_path_exists?("/etc/nginx/sites-enabled/romeo") 
        execute :sudo, :ln, "-s /etc/nginx/sites-available/romeo /etc/nginx/sites-enabled/romeo"
      end
    end
  end

  task :nginx_reload do
    on roles(:web) do
      invoke "deploy:site_symlink"
      execute :sudo, "nginx -s reload"
    end     
  end

  after :publishing, 'deploy:assets_precompile'
  after :assets_precompile, 'deploy:nginx_reload'

end

def remote_path_exists?(path)
  capture("if [ -e '#{path}' ]; then echo -n 'true'; fi").include?("true")
end

