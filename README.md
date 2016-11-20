# Puppet HandsOn
This HandsOn is meant to give you a short introduction to Puppet.
It's based on [Vagrant](https://github.com/puppetlabs/puppet-in-docker) environment and the [puppet-in-docker](https://github.com/puppetlabs/puppet-in-docker) tools.

You should be able to make your first steps with Puppet.
You can take esisting modules for a test drive or build your own modules in a small and portable environment.

# Getting Started
First, start the server which will hold the docker containers for the Puppet master and some other infrastructure services.

```
# vagrant up puppet
```

Once the initial setup is complete, ssh into the server:

```
# vagrant ssh puppet
```

Once inside the vagrant host start the docker-compose environment:

```
# cd /vagrant/pupppet
# docker-compose up -d
```

Wait a few minutes until the puppet stack is up and running. (You can follow the logs with `docker-compose logs -f`. You will see some errors, but those are expected during the bootstrap process.)

Finally install `librarian-puppet`, `r10k` and `puppet-lint` into the puppet container.
(We will need these later.)

```
# docker-compose exec puppet bash -c 'gem install librarian-puppet r10k puppet-lint'
# docker-compose exec puppet bash -c 'apt-get update && apt-get install -y git'
```

## GUIs
First you need to identify forwarded ports

```
# docker ps --format "{{.Names}}:\t{{.Ports}}" | sort | grep puppet | column -t
```

and the IP address of your vagrant machine:

```
# ip a s eth1
```

Not you can check the GUIs on http://<IP>:XXX (in my case the Puppet explorer is running on: http://172.28.128.4:32769/)


# Test
Now it's time to run a first test:

```
# docker run --rm --net puppet_default puppet/puppet-agent-alpine
# docker run --rm --net puppet_default puppet/puppet-agent-ubuntu
```

The above commands should finish with any errors and you should see two nodes in the GUIs:
One ubuntu and one alpine node.


# A Simple Environment
We will start an interactive bash in based on the puppet-agent-ubuntu docker image.
Next we can manage software in this image, add simple files and demonstrate how hiera works.

```
# docker run -it --hostname ubuntu-client-00 --name ubuntu-client-00 --net puppet_default --entrypoint /bin/bash  puppet/puppet-agent-ubuntu
```

First update the package lists:
(Yes we could to this using Puppet - but let's keep it simple.)

```
# apt-get update
```

Now perform a Puppet agent run (**Note** You need to perform the command as root.)

```
# puppet agent --verbose --onetime --no-daemonize --summarize --environment production
```

and check that the demo file is where it belongs

```
# cat /tmp/puppet-in-docker
```

Now open a new shell in the `puppet/code/environments` folder of this HandsOn.

Now create a new environment:

```
# mkdir -p simple/{hieradata,manifests}
# touch simple/hieradata/common.yaml
# touch simple/manifests/site.pp
# touch simple/Puppetfile
```

The resulting structure should look like this:

```
# tree simple/
simple/
|-- hieradata
|   `-- common.yaml
|-- manifests
|   `-- site.pp
`-- Puppetfile

2 directories, 3 files
```

## Managing Software
First add the following content to the `manifests/site.pp` file:

```
package { 'vim':
  ensure => 'installed'
}
```

and check if you have any errors ([syntax](https://puppet.com/blog/verifying-puppet-checking-syntax-and-writing-automated-tests) or [style](http://puppet-lint.com/)):

```
# docker-compose exec puppet puppet parser validate /etc/puppetlabs/code/environments/simple/manifests/site.pp
# docker-compose exec puppet puppet-lint /etc/puppetlabs/code/environments/simple/manifests/site.pp
```

Once you fixed all errors you can go back to your interactive docker instance from above and run

```
# puppet agent --verbose --onetime --no-daemonize --summarize --environment simple
```

You should see the following line in the output:

```
[...]
Notice: /Stage[main]/Main/Package[vim]/ensure: created
[...]
```

To verify run

```
# dpkg -l | grep vim
```

As you can imagine it's not ideal to add one of the above blocks for each package you want to install.
Therefore we can define an array which holds multiple packages and makes sure they get installed.
To do so, modify the code in `manifests/site.pp` to

```
$packages = [ 'vim', 'tree' ]

package { $packages:
  ensure => 'installed'
}
```

You should see

```
[...]
Notice: /Stage[main]/Main/Package[tree]/ensure: created
[...]
```

Finally we will make things 'right' by using hiera and a function from the puppet-stdlib to install the packages:

First modify the content of `manifests/site.pp` to

```
$packages        = hiera('site::packages',[])
ensure_packages($packages) # Requires stdlib but is safer
```

Next add this to your `hieradata/common.yaml`:

```
site::packages:
  - git
  - tree
  - vim
```

Finally add the following content to the `Puppetfile`

```
forge "https://forgeapi.puppetlabs.com"

mod 'puppetlabs-stdlib'
```

and install the module(s) using `librarian-puppet`.

Now you can perform the `puppet agent` run as before to test if everything works.
You should see:

```
[...]
Notice: /Stage[main]/Main/Package[git]/ensure: created
[...]
```

# A little more complex environment
See the `demo` environment for an example how to install and configure docker, ntp and set the timezone.
The environment also makes sure that the Puppet agent itself is configured correctly

# Install modules on the Puppet Server

## librarian-puppet

```
# docker-compose exec puppet bash -c 'cd /etc/puppetlabs/code/environments/production && librarian-puppet install --verbose
```

# r10k

```
# docker-compose exec puppet bash -c 'cd /etc/puppetlabs/code/environments/production && r10k puppetfile install'
```

# Manage Certificates

```
# docker-compose exec puppet puppet cert list --all
# docker-compose exec puppet puppet cert clean <hostname>
```
