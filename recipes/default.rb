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

#packages = node[:redmine][:requirements]
#
#packages.each do |pkg|
#  package pkg
#end

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

rvm_environment "ruby-1.8.7-p330@redmine"

rvm_gem "unicorn" do
  ruby_string "ruby-1.8.7-p330@redmine"
end

rvm_gem "rake" do
  ruby_string "ruby-1.8.7-p330@redmine"
  version "0.8.7"
end

rvm_gem "rails" do
  ruby_string "ruby-1.8.7-p330@redmine"
  version "2.3.14"
end 

template "#{node[:redmine][:app_path]}/.rvmrc" do
  source ".rvmrc.erb"
  owner "www-data"
  group "www-data"
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

execute "rake" do
  command "rake generate_session_store"
  cwd node[:redmine][:app_path]
end

execute "rake" do
  command "rake db:migrate RAILS_ENV=production"
  cwd node[:redmine][:app_path]
end

service "unicorn" do
  action :start
  pattern "unicorn_rails"
  start_command "cd #{node[:redmine][:app_path]} && unicorn_rails -c config/unicorn.rb -E production -D"
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
