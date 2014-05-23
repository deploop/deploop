# This script is only for development. It's a dummy guide in order
# to deploy a Deploop enabled Lambda Architecture cluster.

exit 1

###################################################################
# 1. The fist step is define the Puppet environmet per host:
#
# This match with the Puppet environment configuration
# /etc/puppet/environments/production
#                          preproduction
#                          test
#
# mco rpc <deploop agent> <action> env=<enviroment> 
#
# This command insert on each /etc/puppet/puppet.conf node:
#
#  pluginsync=false  [deploop issue #2]
#  factpath=/var/lib/puppet/facts.d/ [facts location for puppet]
#  environment=production [built-in environment mechanism for puppet]
###################################################################

manager> mco find --with-agent deploop # for sanity checking
manager> mco rpc deploop puppet_environment env=production --with-identity=mncars001
manager> mco rpc deploop puppet_environment env=preproduction --with-identity=mncars001
manager> mco rpc deploop puppet_environment env=test

###################################################################
# 2. For testing the properly enviroment setup we have to run on each node:
###################################################################

agent> puppet agent --configprint environment

###################################################################
# 3. The next one is to deploy de facts for fine tune logic control in puppet master.
#
# In order to makes work this step, we have to run a simple webserver
# pointing to the deploop facts folder
###################################################################

manager> setsid ruby ./simple-webserver.rb

# deploop_collection.rb -> production
# deploop_category.rb -> batch
# deploop_role.rb -> nn1
# deploop_entity.rb -> flume

#
# mco rpc <deploop agent> <action> url=<enviroment> 
# 
# This command download the deploop fact into the agent folder /var/lib/puppet/facts.d
# and update the facters file: /etc/mcollective/facts.yaml
#
manager> mco rpc deploop download_fact url="http://openbus-deploop:8080/deploop_collection.rb" --with-identity=mncars001
manager> mco rpc deploop download_fact url="http://openbus-deploop:8080/deploop_category.rb" --with-identity=mncars001
manager> mco rpc deploop download_fact url="http://openbus-deploop:8080/deploop_role.rb" --with-identity=mncars001
manager> mco rpc deploop download_fact url="http://openbus-deploop:8080/deploop_entity.rb" --with-identity=mncars001

###################################################################
# 4. Getting information
# Check for the new Deploop Fact:
###################################################################

manager> mco rpc rpcutil get_fact fact=deploop_collection
manager> mco rpc rpcutil get_fact fact=deploop_collection
manager> mco ping --with-fact "deploop_collection=/.*/"
manager> mco ping --with-fact "deploop_category=/.*/"
manager> mco inventory mncars001 | grep deploop_
manager> mco plugin doc agent/deploop
manager> mco plugin doc agent/service
manager> mco plugin doc agent/puppet

###################################################################
# 5. Schedule Puppet runs for real deployment:
###################################################################

manager> mco rpc puppet runonce 
manager> mco rpc puppet runonce --with-identity mncars001
manager> mco rpc puppet runonce --batch 2 --batch-sleep 10
manager> mco rpc puppet status --with-identity=mncars001



