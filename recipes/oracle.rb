#
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
# Cookbook:: java
# Recipe:: oracle
#
# Copyright:: 2011, Bryan w. Berry
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

include_recipe 'java::notify'

unless node.recipe?('java::default')
  Chef::Log.warn('Using java::default instead is recommended.')

  # Even if this recipe is included by itself, a safety check is nice...
  if node['java']['java_home'].nil? || node['java']['java_home'].empty?
    include_recipe 'java::set_attributes_from_version'
  end
end

java_home = node['java']['java_home']
arch = node['java']['arch']
version = node['java']['jdk_version'].to_s
tarball_url = node['java']['jdk'][version][arch]['url']
tarball_checksum = node['java']['jdk'][version][arch]['checksum']
bin_cmds = node['java']['jdk'][version]['bin_cmds']

include_recipe 'java::set_java_home'

java_oracle_install 'jdk' do
  url tarball_url
  default node['java']['set_default']
  checksum tarball_checksum
  app_home java_home
  bin_cmds bin_cmds
  alternatives_priority node['java']['alternatives_priority']
  retries node['java']['ark_retries']
  retry_delay node['java']['ark_retry_delay']
  connect_timeout node['java']['ark_timeout']
  use_alt_suffix node['java']['use_alt_suffix']
  reset_alternatives node['java']['reset_alternatives']
  download_timeout node['java']['ark_download_timeout']
  proxy node['java']['ark_proxy']
  action :install
  notifies :write, 'log[jdk-version-changed]', :immediately
end

if node['java']['set_default'] && platform_family?('debian')
  include_recipe 'java::default_java_symlink'
end

include_recipe 'java::oracle_jce' if node['java']['oracle']['jce']['enabled']
