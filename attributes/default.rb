default[:redmine] = {
  :release_tag => "1.3.1",
  :app_path => "/var/www/virtual-hosts/redmine",
  :unicorn_conf => {
    :pid => "/tmp/pids/unicorn.pid", 
    :sock => "/tmp/sockets/unicorn.sock",
    :error_log => "unicorn.error.log",
    :access_log => "unicorn.access.log",
    }
}

normal[:app_server_name] = "redmine"


