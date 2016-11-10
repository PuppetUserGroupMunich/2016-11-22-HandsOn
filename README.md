# Preparation

```
vagrant up puppet
vagrant ssh puppet
```

Once inside the vagrant host

```
cd /vagrant/pupppet
docker-compose up -d
```

Wait a few minutes until the puppet stack is up and running.

Finally install `librarian-puppet` and `r10k`

```
docker-compose exec puppet bash -c 'gem install librarian-puppet'
docker-compose exec puppet bash -c 'gem install r10k'
```

## Test

```
docker run --rm --net puppet_default puppet/puppet-agent-alpine
docker run --rm --net puppet_default puppet/puppet-agent-ubuntu
```

# GUIs

## Identify forwarded Ports

```
docker ps --format "{{.Names}}:\t{{.Ports}}" | sort | grep puppet | column -t
```

## Check the GUIs on http://puppet.vagrant:XXX
You should see two nodes in the GUIs: One ubuntu and one alpine node.

# Test

## Interative Run with Docker
Start an interactive bash in based on the puppet-agent-ubuntu docker image

```
docker run -it --hostname ubuntu-client-00 --name ubuntu-client-00 --net puppet_default --entrypoint /bin/bash  puppet/puppet-agent-ubuntu
```

Now perform a puppet agent run

```
puppet agent --verbose --onetime --no-daemonize --summarize
```

and check that the demo file is where it belongs

```
cat /tmp/puppet-in-docker
```

# Install modules on the Puppet Server

## librarian-puppet

```
docker-compose exec puppet bash -c 'cd /etc/puppetlabs/code/environments/production && librarian-puppet install --verbose
```

# r10k

```
docker-compose exec puppet bash -c 'cd /etc/puppetlabs/code/environments/production && r10k puppetfile install'
```

# Manage Certificates


```
docker-compose exec puppet puppet cert list --all
docker-compose exec puppet puppet cert clean <hostname>
```
