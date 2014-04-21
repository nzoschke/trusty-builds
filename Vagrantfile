# -*- mode: ruby -*-
# vi: set ft=ruby :

DOCKER_HOST = ENV["DOCKER_HOST"] || "localhost:4243"
DOCKER_PORT = DOCKER_HOST.split(":")[1]
  puts "DOCKER_HOST=#{DOCKER_HOST}"

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.network :forwarded_port, guest: 4243, host: DOCKER_PORT

  config.vm.provision "shell", inline: <<-EOF
    apt-get update
    apt-get --yes install docker.io

    # re-configure docker to listen over tcp
    # TODO: make idempotent via .d/ pattern?
    echo 'DOCKER_OPTS="-H unix:///var/run/docker.sock -H tcp://0.0.0.0:4243"' >> /etc/default/docker.io
    restart docker.io && sleep 1

    # verify docker w/ minimal busybox image
    docker.io run busybox /bin/sh -c "busybox | head -1"
  EOF
end
