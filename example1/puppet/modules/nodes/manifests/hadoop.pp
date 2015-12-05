# Class: hadoop
#
# This module manages hadoop
#
# Parameters:
#   $nodes::environment=dev|stage|production - used to read different conf files
#   $nodes::hadoop_home:: home of hadoop (e.g. /home/hadoop)
#   $nodes::hadoop_version = version of Hadoop to deploy
#   $nodes::hadoop_parent_dir = location of the hadoop folder parent - where to extract the variables, create symlinks, etc
#   $nodes::hadoop_datastore = list of mount points to be used for the datanodes
#   $nodes::hadoop_namenode_dir = dfs.name.dir value
#   $nodes::hadoop_default_fs_name - htdfs://host:port/
#   $nodes::mapred_job_tracker - url for the jobtracker (host:port)
#
# Actions:
#  get archive, untar, symlink
#  configure hadoop
#  deploy init.d services
#
# Requires:
#  CentOS / MacOSX
#
# Sample Usage:
#
#  $nodes::hadoop_home:=/home/hadoop/hadoop
#  $nodes::hadoop_datastore=["/var/hadoop_datastore", "/mnt/hadoop_store_2"]
#  $nodes::hadoop_version=0.21.0-SNAPSHOT
#  $nodes::hadoop_parent_dir=/home/hadoop
#  $nodes::hadoop_default_fs_name=hdfs://namenode:9000
#
#  include hadoop
#  include services::hadoop-namenode
class hadoop {
  # get files
  file { "hadoop-file":
    path    => "$nodes::hadoop_parent_dir/hadoop-$nodes::hadoop_version.tar.gz",
    source  => "/home/hadoop-$nodes::hadoop_version.tar.gz",
    backup  => false,
    owner   => "root",
    group   => "root",
    require => Exec["hadoop_download"],
  }
  exec { "hadoop_download":
    cwd      => [ '/home/'],
    path     => [ '/home/' ,'/bin', '/usr/bin' ],
    command  => "wget $nodes::base_hadoop_url/hadoop/common/hadoop-$nodes::hadoop_version/hadoop-$nodes::hadoop_version.tar.gz",
    timeout => "0",
    creates  => "/home/hadoop-$nodes::hadoop_version.tar.gz",
  }

  exec { "hadoop_untar":
    command => "tar xzf hadoop-$nodes::hadoop_version.tar.gz; chown -R $nodes::user:$nodes::group/home/hadoop/hadoop-$nodes::hadoop_version",
    cwd     => "$nodes::hadoop_parent_dir/",
    require => File["hadoop-file"],
    creates => "$nodes::hadoop_parent_dir/hadoop-$nodes::hadoop_version",
  }

  file { "hadoop-reown-build":
    path    => "$nodes::hadoop_parent_dir/hadoop-$nodes::hadoop_version",
    backup  => false,
    recurse => true,
    owner   => "$nodes::user",
    group   => "$nodes::group",
    require => Exec["hadoop_untar"],
    ensure  => symlink,
  }

  file { "$nodes::hadoop_home/pids":
    path    =>"$nodes::hadoop_home/pids",
    backup  => false,
    ensure  => directory,
    owner   => "$nodes::user",
    group   => "$nodes::group",
    mode    => 644,
    require => File["hadoop-reown-build"],
  }

  file { $nodes::hadoop_datastore:
    path   => "$nodes::hadoop_datastore",
    backup => false,
    ensure => directory,
    owner  => "$nodes::user",
    group  => "$nodes::group",
    mode   => 644,
  }

  file { "/var/hadoop_namenode":
    path   => "/var/hadoop_namenode",
    backup => false,
    ensure => directory,
    owner  => "$nodes::user",
    group  => "$nodes::group",
    mode   => 644,
  }

  #define logging paths
  $log_path = "/var/log/hadoop/"

  include hadoop::copy_conf
  include hadoop::copy_services
}

class hadoop::copy_conf {
  #put the HDFS configuration
  file { "hdfs-site-xml":
    path    => "$nodes::hadoop_home/conf/hdfs-site.xml",
    content => template("nodes/hdfs-site.xml.erb"),
    owner   => "$nodes::user",
    group   => "$nodes::group",
    mode    => 644,
    ensure  => file,
    require => File["hadoop-reown-build"],
  }

  file { "core-site-xml":
    path    => "$nodes::hadoop_home/conf/core-site.xml",
    content => template("nodes/core-site.xml.erb"),
    owner   => "$nodes::user",
    group   => "$nodes::group",
    mode    => 644,
    ensure  => file,
    require => File["hadoop-reown-build"],
  }

  /*file { "mapred-site-xml":
    path => "$nodes::{hadoop_home}/conf/mapred-site.xml",
    content => template("hadoop/conf/$nodes::{environment}/mapred-site.xml.erb"),
    owner => "$nodes::user:",
    group => $nodes::group,
    mode => 644,
    ensure => file,
    require => File["$nodes::hadoop_home:"],
  }

  $nodes::java_home= $nodes::operatingsystem ?{
    Darwin => "/System/Library/Frameworks/JavaVM.framework/Versions/1.6.0/Home/",
    redhat => "/usr/java/latest",
    CentOS => "/usr/java/latest",
    default => "/usr/lib/jvm/java-6-sun",
  }

  file { "hadoop-env":
    path => "$nodes::{hadoop_home}/conf/hadoop-env.sh",
    content => template("hadoop/conf/$nodes::{environment}/hadoop-env.sh.erb"),
    owner => "$nodes::user:",
    group => $nodes::group,
    mode => 644,
    ensure => file,
    require => File["$nodes::hadoop_home:"],
  }

  file { "hadoop_log_folder":
    path => $nodes::log_path,
    owner => "$nodes::user:",
    group => $nodes::group,
    mode => 644,
    ensure => directory,
    require => File["$nodes::hadoop_home:"],
  }

  file { "hadoop_log4j":
    path => "$nodes::hadoop_home:/conf/log4j.properties",
    owner => "$nodes::user:",
    group => $nodes::group,
    mode => 644,
    content => template("hadoop/conf/$nodes::{environment}/log4j.properties.erb"),
    require => File["$nodes::hadoop_home:"],
  }

  file {"hadoop_masters":
    path => "$nodes::hadoop_home:/conf/masters",
    owner => "$nodes::user:",
    group => $nodes::group,
    mode => 644,
    content => template("hadoop/conf/$nodes::{environment}/masters.erb"),
    require => File["$nodes::hadoop_home:"],
  }

  file {"hadoop_slaves":
    path => "$nodes::hadoop_home:/conf/slaves",
    owner => "$nodes::user:",
    group => $nodes::group,
    mode => 644,
    content => template("hadoop/conf/$nodes::{environment}/slaves.erb"),
    require => File["$nodes::hadoop_home:"],
  }*/
}

class hadoop::copy_services {
  #install the hadoop services
  $init_d_path =  "/etc/init.d/hadoop"

  $init_d_template = "nodes/hadoop.erb"

  file { "hadoop-start-all-service":
    path    => $init_d_path,
    content => template($init_d_template),
    ensure  => file,
    owner   => "$nodes::user",
    group   => "$nodes::group",
    mode    => 755
  }
  /*file { "hadoop-namenode-service":
    path => "/etc/init.d/hadoop-namenode",
    content => template("hadoop/service/$nodes::{os}/hadoop-namenode.erb"),
    ensure => file,
    owner => "root",
    group => "root",
    mode => 755
  }

  file { "hadoop-datanode-service":
    path => "/etc/init.d/hadoop-datanode",
    content => template("hadoop/service/$nodes::{os}/hadoop-datanode.erb"),
    ensure => file,
    owner => "root",
    group => "root",
    mode => 755
  }

  file { "hadoop-secondarynamenode-service":
    path => "/etc/init.d/hadoop-secondarynamenode",
    content => template("hadoop/service/$nodes::{os}/hadoop-secondarynamenode.erb"),
    ensure => file,
    owner => "root",
    group => "root",
    mode => 755
  }

  file { "hadoop-jobtracker-service":
    path => "/etc/init.d/hadoop-jobtracker",
    content => template("hadoop/service/$nodes::{os}/hadoop-jobtracker.erb"),
    ensure => file,
    owner => "root",
    group => "root",
    mode => 755
  }

  file { "hadoop-tasktracker-service":
    path => "/etc/init.d/hadoop-tasktracker",
    content => template("hadoop/service/$nodes::{os}/hadoop-tasktracker.erb"),
    ensure => file,
    owner => "root",
    group => "root",
    mode => 755
  }*/
}
