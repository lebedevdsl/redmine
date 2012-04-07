Redmine Cookbook 
================

Description
-----------

Chef cookbook for deploying redmine instance
Currently there is only one recipe.

* redmine::default - installs and configures redmine 1.3.1 on nginx->unicorn

### Attributes

* ['redmine']['app_path'] - application path
* ['redmine']['release_tag'] - repository tag for fetching defined release
* ['redmine']['ruby'] - ruby version for run redmine
* ['redmine']['rmagick'] - adds rmagick support if enabled
