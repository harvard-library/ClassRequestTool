namespace :bower do
  desc 'Install bower'
  task :install do
    on roles(:web) do
      within release_path do
        execute :rake, 'bower:install CI=true'
      end
    end
  end
end
before 'deploy:compile_assets', 'bower:install'


set :application, 'class_request_tool'
# set :repo_url, 'git@github.com:harvard-library/ClassRequestTool.git'

ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_via, :copy

set :scm, :git

set :format, :pretty
# set :log_level, :debug
# set :pty, true

# Create these in /path/to/deploy/shared
set :linked_files, %w{config/database.yml config/mailer.yml.erb config/reports.yml .env}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/assets public/system public/uploads}

set :keep_releases, 3

namespace :deploy do

  desc 'Run arbitrary remote rake task'
  task :rrake do
    on roles(:app) do
      within release_path do
        execute :rake, "#{ENV['T']} --rakefile=#{release_path}/Rakefile RAILS_ENV=#{Proc.new do fetch(:rails_env) end.call}"
      end
    end
  end

  desc 'Restart application'
  task :restart do
    invoke 'delayed_job:restart'
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :crontab do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        execute :rake, "crt:cron_task:setup_crontab --rakefile=#{release_path}/Rakefile RAILS_ENV=#{Proc.new do fetch(:rails_env) end.call}"
      end
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
  after :finishing, :cleanup

end

# In order to see RVM while not part of a deploy
before 'deploy:migrate', 'rvm:hook'
before 'deploy:rrake', 'rvm:hook'
before 'bundler:install', 'rvm:hook'
