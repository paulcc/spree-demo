set :application, "spree-demo"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/spreedemo/live"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
set :scm, :git
set :repository, "git://github.com/schof/spree-demo.git"
set :branch, "master"
set :git_enable_submodules, true

server "sl4-spree.endpoint.com", :app, :web, :db, :primary => true
#role :app, "your app-server here"
#role :web, "your web-server here"
#role :db,  "your db-server here", :primary => true

set :user, "spreedemo"
set :use_sudo, false
set :deploy_via, :remote_cache

namespace :deploy do
  desc "Tells Passenger to restart the app."
  task :restart do
    run "cd #{release_path}; mongrel_rails cluster::restart"
    #run "touch #{current_path}/tmp/restart.txt"
  end  
  desc "Sylink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/mongrel_cluster.yml #{release_path}/config/mongrel_cluster.yml"
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  desc "Run the rake bootstrap task."
  task :rake_bootstrap do
    run("cd #{release_path}; rake demo:bootstrap RAILS_ENV=production")
  end
end
after 'deploy:update_code', 'deploy:symlink_shared'
after 'deploy:update_code', 'deploy:rake_bootstrap'