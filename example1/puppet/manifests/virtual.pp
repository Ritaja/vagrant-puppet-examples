# virtual.pp
#
# People accounts of interest as virtual resources

class virtual_users {
  package { "ruby-shadow":
    ensure => installed
  }

  @user { "hadoop":
    ensure     => "present",
    uid        => "1001",
    gid        => "1001",
    comment    => "Hadoop",
    home       => "/home/hadoop",
    shell      => "/bin/bash",
    managehome => true,
    password   => '$1$5dZQgQSq$POqlSWnuiYZ7d1VXfgXGo.',
    require    => [Group["hadoop"], Package["ruby-shadow"]]
  }

  exec { "genkey":
    command => "su hadoop -c 'ssh-keygen -t dsa -f ~/.ssh/id_dsa'",
    cwd     => "/root",
    creates => "/home/hadoop/.ssh/id_dsa",
    require => User["hadoop"],
    unless  => "cat /home/hadoop/.ssh/id_dsa",
  }

  exec { "authkey":
    command => "cat ./id_dsa.pub >> ./authorized_keys",
    cwd     => "/home/hadoop/.ssh/",
    creates => "/home/hadoop/.ssh/authorized_keys",
    require => Exec["genkey"],
    unless  => "cat /home/hadoop/.ssh/authorized_keys",
  }


  file { "/home/hadoop/.ssh":
    ensure  => directory,
    require => User["hadoop"],
  }

  file { "/home/hadoop/.ssh/id_dsa":
    content => template("ssh_keys/keys/id_dsa"),
    ensure  => present,
    owner   => hadoop,
    group   => hadoop,
    mode    => 600,
    require => User["hadoop"],
  }

  file { "/home/hadoop/.ssh/id_dsa.pub":
    content => template("ssh_keys/keys/id_dsa.pub"),
    ensure  => present,
    owner   => hadoop,
    group   => hadoop,
    mode    => 600,
    require => User["hadoop"],
  }

  file { "/home/hadoop/.ssh/authorized_keys":
    mode  => 600,
    owner => hadoop,
    group => hadoop,
  }

  ssh_authorized_key { "rsengupta":
    type    => ssh-dsa,
    key     => template("ssh_keys/keys/authorized_keys"),
    user    => hadoop,
    target  => "/home/hadoop/.ssh/authorized_keys",
    ensure  => present,
    require => User["hadoop"],
  }


  sshkey { "hadoop":
    type => ssh-rsa,
    key  => template("ssh_keys/keys/authorized_keys"),
  }
}

class virtual_groups {
  @group { "hadoop":
    ensure  => "present",
    gid     => "1001",
  }

}