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
include_recipe recipe[rvm]

packages = node[:redmine][:requirements]

packages.each do |pkg|
  package pkg
end

git node[:redmine][:path] do
  action :export
  user 'www-data'
  group 'www-data'
  repository "git://github.com/edavis10/redmine"
  revision node[:redmine][:release_tag]
end

rvm_environment "1.8.7@redmine"

template "#{node[:redmine][:app_path}" do
  source ".rvmrc"
end

template "#{node[:redmine][:app_path]}/config/unicorn.rb" do
  source "unicorn.rb"
end

service "unicorn" do
  action :start
end

service "nginx" do
  action :reload
end
