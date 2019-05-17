# illinois-shibboleth-sp-img

A Docker image of the Illinois Shibboleth Service Provider (SP).

## Developer build and test

To build all the images locally for development run the following command:
```
$ make up
$ make test
$ make down
```

The images will be tagged with the 'local' tag.

## Docker Hub build and test

To download and test the latest containers as they exist on Docker Hub type:
```
$ docker-compose up -d
$ make test
$ docker-compose down
```

## Install Vagrant

brew cask install vagrant
vagrant plugin install vagrant-scp
vagrant scp ~/.ssh/id_rsa shib-in-a-box:~/.ssh
vagrant scp ~/.aws shib-in-a-box:~
vagrant scp ~/.aws-login shib-in-a-box:~
