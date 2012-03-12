#
# Cookbook Name:: redmine
# Recipe:: default
#
# Copyright 2012, Oversun-Scalaxy LTD
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe 'rvm::system_install'

REDMINE_RUBY = "ruby-1.8.7-p330@redmine"
REQUIRED_GEMS = {
  "rake"    => "0.8.7",
  "rails"   => "2.3.14",
  "unicorn" => nil,
  "rubytree" => "0.5.2" 
  }

service "unicorn_rails" do
  supports :restart => true
  action :nothing
  start_command "cd #{node[:redmine][:app_path]} && unicorn_rails -c config/unicorn.rb -E production -D"
  stop_command "killall unicorn_rails"
end

directory node[:redmine][:app_path] do
  action :create
  owner "www-data"
  group "www-data"
end

git node[:redmine][:app_path] do
  action :export
  user 'www-data'
  group 'www-data'
  repository "https://github.com/redmine/redmine"
  revision node[:redmine][:release_tag]
end

rvm_environment REDMINE_RUBY

REQUIRED_GEMS.each do |gem, version|
  rvm_gem gem do
    ruby_string REDMINE_RUBY
    version version if version
  end
end

template "#{node[:redmine][:app_path]}/.rvmrc" do
  source ".rvmrc.erb"
  owner "www-data"
  group "www-data"
end

script "trust_rvmrc" do 
  interpreter "bash"
  code <<-EOF
  source /etc/profile
  rvm rvmrc trust #{node[:redmine][:app_path]}
  EOF
end

template "#{node[:redmine][:app_path]}/config/unicorn.rb" do
  source "unicorn.rb.erb"
  owner "www-data"
  group "www-data"
end

template "#{node[:redmine][:app_path]}/config/database.yml" do
  source "database.yml.erb"
  owner "www-data"
  group "www-data"
end

rvm_shell "rake_task:generate_session_store" do
  ruby_string REDMINE_RUBY
  cwd node[:redmine][:app_path]
  code "rake generate_session_store"
end

rvm_shell "rake_task:db:migrate RAILS_ENV=production" do
  ruby_string REDMINE_RUBY
  cwd node[:redmine][:app_path]
  code "rake db:migrate RAILS_ENV=production"
  notifies :restart, resources(:service => "unicorn_rails")
end

template "/etc/nginx/sites-available/redmine.conf" do
  source "redmine.conf.erb"
end

link "/var/www/virtual-hosts/redmine" do
  to "/opt/redmine"
end

link "/etc/nginx/sites-enabled/redmine.conf" do
  to "/etc/nginx/sites-available/redmine.conf"
  notifies :reload, resources(:service => "nginx")
end
