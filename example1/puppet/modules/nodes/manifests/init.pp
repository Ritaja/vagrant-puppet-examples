# puppet roles for different servers

class nodes {
  $hadoop_version="2.7.1"
  $hadoop_parent_dir="/home/hadoop"
  $base_hadoop_url="http://www.eu.apache.org/dist/"
  $user="vagrant"
  $group="vagrant"
  $hadoop_namenode_dir = "/var/hadoop_namenode/"
  $hadoop_default_fs_name = "hdfs://localhost:9000/"
  $hadoop_datastore = ["/home/hadoop_data/"]
  $mapred_job_tracker = "localhost:9001"
  #$hadoop_mapred_local = ["/mnt/data_1/hadoop_mapred_local/", "/mnt/data_2/hadoop_mapred_local/"]
  $hadoop_home="/home/hadoop/hadoop"
  $hadoop_from_source = false
  include hadoop
}

