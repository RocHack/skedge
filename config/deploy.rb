lock '3.4.0'
set :application, 'skedgeur.com'
set :repo_url, "git@bitbucket.org:dhassin/skedge2.git"
set :use_sudo, true

ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, "/home/deploy/skedgeur.com"
set :scm, :git
set :git_shallow_clone, 1

set :format, :pretty
set :log_level, :debug
set :pty, true

set :user, 'deploy'

set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system} # used to have 'bin' too
set :bundle_binstubs, nil

set :keep_releases, 3

namespace :deploy do

  desc 'Stop application'
  task :stop do
    on roles(:app, :web), in: :sequence do
      execute "sudo kill `cat #{current_path}/tmp/pids/unicorn.pid`" rescue nil
    end
  end

  desc 'Start application'
  task :start do
    on roles(:app, :web), in: :sequence do
      execute "source /home/deploy/.profile && cd #{current_path} && bundle exec unicorn -c config/unicorn.rb -E #{fetch(:default_env)[:rails_env]} -D"
    end
  end

  desc "Restart web-server"
  task :restart do
    Rake::Task['deploy:stop'].execute rescue nil
    Rake::Task['deploy:start'].execute
  end rescue nil

  after :published, :restart rescue nil
end

desc "Scrape"
task :scrape do
  on roles(:app, :web), in: :sequence do
    depts = ENV['depts'] ? "depts=#{ENV['depts']}" : ""
    yrterm = ENV['yrterm'] ? "yrterm=#{ENV['yrterm']}" : ""
    execute "source /home/deploy/.profile && cd #{current_path} && bundle exec rake scrape #{depts} #{yrterm}"
  end
end rescue nil

desc "Tail log"
task :log do
  on roles(:app, :web), in: :sequence do
    execute "tail -F #{current_path}/log/unicorn.log"
  end
end rescue nil

