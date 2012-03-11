default[:redmine] = {
  :release_tag => "1.3.1",
  :app_path => "/opt/redmine",
  :unicorn_conf => {
    :pid => "/tmp/pids/unicorn.pid", 
    :sock => "/tmp/sockets/unicorn.sock",
    :error_log => "unicorn.error.log",
    :access_log => "unicorn.access.log"
    },
  :db => {
    :db_name => "redmine",
    :db_host => "localhost",
    :db_user => "redmine",
    :db_pass => ""
  }

}

normal[:app_server_name] = "redmine"
set[:redmine][:db] = {
  :db_name => "redmine",
  :db_host => "localhost",
  :db_user => "redmine",
  :db_pass => ""
}

