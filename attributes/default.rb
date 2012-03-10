default[:redmine] = {
  :release_tag => "1.3.1"
  :app_path => "/var/www/redmine"
  :release_tag => "1.3.1",
  :app_path => "/var/www/redmine",
  :unicorn_conf => {
    :pid => "/tmp/pids/unicorn.pid" 
    :sock => "/tmp/socks/unicorn.sock"
    :error_log => "unicorn.error.log"
    :access_log => "unicorn.access.log"
    :pid => "/tmp/pids/unicorn.pid", 
    :sock => "/tmp/socks/unicorn.sock",
    :error_log => "unicorn.error.log",
    :access_log => "unicorn.access.log",
    }
}


