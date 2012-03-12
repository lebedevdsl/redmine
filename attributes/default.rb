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
    :type => "mysql",
    :db_name => "",
    :db_host => "",
    :db_user => "",
    :db_pass => ""
  }

}

set_unless[:redmine][:app_server_name] = "redmine.#{node[:fqdn]}"
set_unless[:redmine][:db] = {
  :db_name => "",
  :db_host => "",
  :db_user => "",
  :db_pass => ""
}
