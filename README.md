Deploop: The Hadoop Deploy System
=================================

Deploop is a tool for provisioning, managing and monitoring Apache Hadoop 
clusters focused in the Lambda Architecture. LA is a generic design based 
on the concepts of Twitter engineer Nathan Marz. This generic architecture 
was designed addressing common requirements for big data.

Deploop system is based on three software components:

The Deploop engine: a CLI tool for cluster deployment and operation.
The Deploop Puppet Enviroments Catalog: A set of puppet recipes for configuration management.
The Deploop Mcollective Agent: An special agent for specific Deploop operations in nodes.
The Deploop GUI: A graphic user interface for easy deployments.

This project is in heavy development, however you can play with the CLI command,
and deploy from scratch a full Hadoop cluster (with HA and kerberos) with a simple
command like this:

    # deploop -f conf/deploy.json --deploy batch

Shutting down the cluster:

    # deploop --layer batch --stop
    checking proper environment ...
    shutting down DataNode workers....
    shutting down Zkfc ....
    shutting down QJM ....
    shutting down Zookeeper Esemble....
    shutting down NameNodes and ResourceManager ....
    shutting down Hisotry server ...

Start up the cluster:

    # deploop --layer batch --start
    checking proper environment ...
    starting up Zookeeper Esemble....
    starting up QJM ....
    starting up NameNodes and ResourceManager ....
    starting up Zkfc ....
    Hisotry server starting up ...
    starting up DataNode workers....

Project info
------------

http://deploop.github.io/


Pull request flow
------------------

Clone the repository from your project fork:

$ git clone https://github.com/deploop/deploop.git

The clone has as active branch the "development branch"

$ git branch
* development

Yo have to make your changes in the "development branch".

$ git add .

$ git commit -m "...."

$ git push origin

When you are ready to purpose a change to the original repository, you have
to use the "Pull Request" button from GitHub interface.

The point is the pull request have to go to the "development branch" so the pull
request revisor can check the change, pull to original "development branch", and 
the last step is to push this "development pull request" to the "master branch".

So the project has two branches:

1. The "master branch": The deployable branch, only hard tested code and ready to use.
2. The "development branch": Where the work is made and where the pull request has to make.

