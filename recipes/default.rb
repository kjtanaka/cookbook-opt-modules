#
# Cookbook Name:: environment-modules
# Recipe:: default
#
# Copyright 2014, FutureGrid, Indiana University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

modules_download_url = node['modules']['download_url']
modules_source_dir = node['modules']['source_dir']
modules_install_dir = node['modules']['install_dir']
modules_version = node['modules']['version']

case node[:platform]
when "redhat", "centos"
  packages = %w[autoconf
                automake
                binutils
                bison
                flex
                gcc
                gcc-c++
                gdb
                gettext
                libtool
                make
                pkgconfig
                redhat-rpm-config
                rpm-build
                strace
                automake14
                automake15
                automake16
                automake17
                byacc
                cscope
                ctags
                cvs
                dev86
                diffstat
                dogtail
                doxygen
                elfutils
                gcc-gfortran
                indent
                ltrace
                oprofile
                patchutils
                pstack
                python-ldap
                rcs
                splint
                subversion
                swig
                systemtap
                texinfo
                valgrind
                tcl
	              tcl-devel
	              tk
	              tk-devel]
when "ubuntu", "debian"
  packages = %w[build-essential]
end

packages.each do |pkg|
  package pkg do
    action :install
  end
end

directory modules_source_dir do
  action :create
end

remote_file "#{modules_source_dir}/modules-#{modules_version}.tar.gz" do
  source modules_download_url
  mode 00644
  owner "root"
  group "root"
  action :create_if_missing
end

execute "untar_modules_tarball" do
  command "tar zxvf modules-#{modules_version}.tar.gz"
  cwd modules_source_dir
  creates "#{modules_source_dir}/modules-#{modules_version}"
end

script "install_modules" do
  interpreter "bash"
	user "root"
  cwd "#{modules_source_dir}/modules-#{modules_version}"
  code <<-EOH
  ./configure --prefix=#{modules_install_dir}/modules-#{modules_version}
  make
  make install
  EOH
  creates "#{modules_install_dir}/modules-#{modules_version}"
end