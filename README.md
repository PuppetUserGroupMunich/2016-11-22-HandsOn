# Preparation

```
vagrant up
vagrant ssh
```

Once inside the vagrant host

```
cd /vagrant/pupppet
docker-compose up -d
```

# Test

```
docker run --rm --net puppet_default puppet/puppet-agent-alpine
docker run --rm --net puppet_default puppet/puppet-agent-ubuntu
```

## Identify forwarded Ports

```
docker ps --format "{{.Names}}:\t{{.Ports}}" | sort | grep puppet | column -t
```

## Check the GUIs on http://puppet.vagrant:XXX
You should see two nodes in the GUIs: One ubuntu and one alpine node.

# Interative Run with Docker
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

# r10k on the PuppetServer

```
docker-compose exec puppet gem install r10k
docker-compose exec puppet bash -c 'cd /etc/puppetlabs/code/environments/production && r10k puppetfile install'
```


