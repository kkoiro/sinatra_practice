app_root = File.expand_path('../../', __FILE__)

worker_processes 2
working_directory app_root

preload_app true
timeout 60

listen 8080
#listen "#{app_root}/tmp/unicorn.sock"
pid "#{app_root}/tmp/unicorn.pid"

stdout_path "#{app_root}/log/unicorn.stdout.log"
stderr_path "#{app_root}/log/unicorn.stderr.log"
