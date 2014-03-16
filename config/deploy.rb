set :application, 'skedge'
set :repo_url, "https://github.com/RocHack/skedge.git"
set :use_sudo, true

ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, "/home/deploy/rails/skedge"
set :scm, :git

set :format, :pretty
set :log_level, :debug
set :pty, true

set :user, 'deploy'

#set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :keep_releases, 5

passenger_user = 'deploy'
passenger_port = '80'

sudo = passenger_port == '80' ? 'sudo' : ''

namespace :deploy do

  desc 'Stop application'
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo service apache2 stop"
    end
  end

  desc 'Start application'
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo service apache2 start"
    end
  end

  desc 'Restart application'
  task :restart do
    invoke "deploy:stop"
    invoke "deploy:start"
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :finishing, 'deploy:cleanup'

end
