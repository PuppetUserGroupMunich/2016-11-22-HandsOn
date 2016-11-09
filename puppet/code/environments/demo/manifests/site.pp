hiera_include('classes')

File { backup => false }

node default {
  file { '/tmp/puppet-in-docker':
    ensure  => present,
    content => "This file is for demonstration purposes only\n",
  }
  file { '/tmp/environment':
    ensure  => present,
    content => "demo\n",
  }
}
