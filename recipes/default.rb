#TODO:
# 1. init.d scripts for unicorn_rails service
# 2. [rvm] Prefer user installation over system-wide
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
REDMINE_RUBY = node[:redmine][:ruby]
REQUIRED_GEMS = {
  "rake"    => "0.8.7",
  "rails"   => "2.3.14",
  "rack"    => "1.1.3",
  "unicorn" => nil,
  "rubytree" => "0.5.2" ,
  "mysql" => nil
  }

include_recipe 'rvm::system_install'

case node[:redmine][:db][:type]
when "mysql"
  package 'mysql-client'
  package "libmysqlclient-dev"
end

service "unicorn_redmine" do
  supports :restart => true, :reload => true
  action :nothing
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

if node[:redmine][:rmagick] == "enabled"
  package "libmagick9-dev"
  rvm_gem "rmagick" do
    ruby_string REDMINE_RUBY
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

template "/etc/init.d/unicorn_redmine" do
  source "unicorn_init_script.erb"
  owner  "root"
  group  "root"
  mode   "0700"
end

template "#{node[:redmine][:app_path]}/config/configuration.yml" do
  source "configuration.yml.erb"
  owner "www-data"
  group "www-data"
  mode  "0644"
  notifies :reload, resources(:service => "unicorn_redmine")
end

template "#{node[:redmine][:app_path]}/config/unicorn.rb" do
  source "unicorn.rb.erb"
  owner "www-data"
  group "www-data"
  mode  "0644"
  notifies :restart, resources(:service => "unicorn_redmine"), :immediately
end

template "#{node[:redmine][:app_path]}/config/database.yml" do
  source "database.yml.erb"
  owner "www-data"
  group "www-data"
  mode  "0644"
end

directory "#{node[:redmine][:app_path]}/public/plugin_assets" do
  owner "www-data"
  group "www-data"
  mode  "0755"
end

rvm_shell "rake_task:generate_session_store" do
  ruby_string REDMINE_RUBY
  cwd node[:redmine][:app_path]
  code "rake generate_session_store"
end

unless node[:redmine][:db].any?{|key, value| value == ""}
  rvm_shell "rake_task:db:migrate RAILS_ENV=production" do
    ruby_string REDMINE_RUBY
    cwd node[:redmine][:app_path]
    code "rake db:migrate RAILS_ENV=production"
    notifies :restart, resources(:service => "unicorn_redmine")
  end
end

template "/etc/nginx/sites-available/redmine.conf" do
  source "redmine.conf.erb"
end

link "/var/www/virtual-hosts/redmine" do
  to node[:redmine][:app_path]
end
  
if node[:nginx]
  link "/etc/nginx/sites-enabled/redmine.conf" do
    to "/etc/nginx/sites-available/redmine.conf"
    notifies :reload, resources(:service => "nginx")
  end
end
