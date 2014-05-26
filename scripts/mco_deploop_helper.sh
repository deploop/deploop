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
# deploop_collection.rb -> production
#
#   Facter.add(:deploop_collection) do
#      setcode "echo production"
#   end
#
# deploop_category.rb -> batch
# deploop_role.rb -> nn1
# deploop_entity.rb -> flume
###################################################################

#
# mco rpc <deploop agent> <action> fact=<fact name> value=<fact values>
# 
# This command create the deploop fact into the agent folder /var/lib/puppet/facts.d
# and update the facters file: /etc/mcollective/facts.yaml
#

manager> mco rpc deploop create_fact fact='collection' value='production' --with-identity=mncars001
manager> mco rpc deploop create_fact fact='category' value='batch' --with-identity=mncars001
manager> mco rpc deploop create_fact fact='role' value='nn1' --with-identity=mncars001
manager> mco rpc deploop create_fact fact='entity' value='flume kafka whatever' --with-identity=mncars001

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

###################################################################
# 6. Command execution
###################################################################
manager> mco rpc deploop execute cmd='cat /etc/puppet/puppet.conf | grep environment' --with-identity=mncars001
manager> mco rpc deploop execute cmd='ls -l' --with-identity=mncars001
manager> mco rpc deploop execute cmd='uname -a' --with-identity=mncars001

###################################################################
# Some usefull commnads
###################################################################
manager> mco rpc service start service=atd --with-identity mncars001
manager> mco rpc service stop service=atd --with-identity mncars001
manager> mco rpc service status service=atd --with-identity mncars001


###################################################################
# 6. Coomand guide for Hadoop setup
###################################################################
[ This command need comment out -> /etc/sudores: Defaults    requiretty]
manager> mco rpc deploop execute cmd='sudo -E /etc/init.d/zookeeper-server start' --with-identity=mncars001

# Zookeeper Esemble startup
manager> mco rpc service start service=zookeeper-server --with-identity mncars001
manager> mco rpc service start service=zookeeper-server --with-identity mncars002
manager> mco rpc service start service=zookeeper-server --with-identity mncars003

# Zookeeper znode for Automatic Failover
manager> mco rpc deploop execute cmd='source /etc/profile.d/java.sh && sudo -E -u hdfs hdfs zkfc -formatZK -force' --with-identity=mncars001

# QJM startup
manager> mco rpc service start service=hadoop-hdfs-journalnode --with-identity mncars001
manager> mco rpc service start service=hadoop-hdfs-journalnode --with-identity mncars002
manager> mco rpc service start service=hadoop-hdfs-journalnode --with-identity mncars003

# HDFS format initialization
manager> mco rpc deploop execute cmd='source /etc/profile.d/java.sh && sudo -E -u hdfs hdfs namenode -format' --with-identity=mncars001

# Namenodes startup
manager> mco rpc service start service=hadoop-hdfs-namenode --with-identity mncars001
manager> mco rpc deploop execute cmd='source /etc/profile.d/java.sh && sudo -E -u hdfs hdfs namenode -bootstrapStandby' --with-identity=mncars002
manager> mco rpc service start service=hadoop-hdfs-namenode --with-identity mncars002

# Automatic Failover startup
manager> mco rpc service start service=hadoop-hdfs-zkfc --with-identity mncars001
manager> mco rpc service start service=hadoop-hdfs-zkfc --with-identity mncars002

# Testing HA
manager> mco rpc deploop execute cmd='source /etc/profile.d/java.sh && sudo -E -u hdfs hdfs haadmin -getServiceState nn1' --with-identity=mncars001
manager> mco rpc deploop execute cmd='source /etc/profile.d/java.sh && sudo -E -u hdfs hdfs haadmin -getServiceState nn2' --with-identity=mncars001

# Workers startup 
manager> mco rpc service start service=hadoop-hdfs-datanode --with-identity mncars004
manager> mco rpc service start service=hadoop-hdfs-datanode --with-identity mncars005
manager> mco rpc service start service=hadoop-hdfs-datanode --with-identity mncars006

# HDFS Filesystem housekeeping
manager> mco rpc deploop execute cmd='source /etc/profile.d/java.sh && sudo -E -u hdfs hadoop fs -mkdir /tmp' --with-identity=mncars001
manager> mco rpc deploop execute cmd='source /etc/profile.d/java.sh && sudo -E -u hdfs hadoop fs -chmod -R 1777 /tmp' --with-identity=mncars001
manager> mco rpc deploop execute cmd='source /etc/profile.d/java.sh && sudo -E -u hdfs hdfs dfs -ls -R /' --with-identity=mncars001
manager> mco rpc deploop execute cmd='source /etc/profile.d/java.sh && sudo -E -u hdfs hdfs dfsadmin -printTopology' --with-identity=mncars001
manager> mco rpc deploop execute cmd='source /etc/profile.d/java.sh && sudo -E -u hdfs hdfs dfsadmin -report' --with-identity=mncars001

# YARN and MRv2
manager> mco rpc deploop execute cmd='source /etc/profile.d/java.sh && sudo -E -u hdfs hadoop fs -mkdir -p /user/history' --with-identity=mncars001
manager> mco rpc deploop execute cmd='source /etc/profile.d/java.sh && sudo -E -u hdfs hadoop fs -mkdir /user/history/done_intermediate' --with-identity=mncars001
manager> mco rpc deploop execute cmd='source /etc/profile.d/java.sh && sudo -E -u hdfs hadoop fs -chown -R mapred:mapred /user/history' --with-identity=mncars001
manager> mco rpc deploop execute cmd='source /etc/profile.d/java.sh && sudo -E -u hdfs hadoop fs -chmod -R 777 /user/history' --with-identity=mncars001

# HistoryServer
manager> mco rpc service start service=hadoop-mapreduce-historyserver --with-identity mncars003
manager> mco rpc deploop execute cmd='source /etc/profile.d/java.sh && sudo -E -u hdfs hadoop fs -mkdir -p /var/log/hadoop-yarn' --with-identity=mncars001
manager> mco rpc deploop execute cmd='source /etc/profile.d/java.sh && sudo -E -u hdfs hadoop fs -chown yarn:mapred /var/log/hadoop-yarn
' --with-identity=mncars001

# MRv2 user
manager> mco rpc deploop execute cmd='source /etc/profile.d/java.sh && sudo -E -u hdfs hadoop fs -mkdir -p /user/jroman' --with-identity=mncars001
manager> mco rpc deploop execute cmd='source /etc/profile.d/java.sh && sudo -E -u hdfs hadoop fs -chown jroman /user/jroman' --with-identity=mncars001

# YARN ResourceManager and workers startup
manager> mco rpc service start service=hadoop-yarn-resourcemanager --with-identity mncars003
manager> mco rpc service start service=hadoop-yarn-nodemanager --with-identity mncars004
manager> mco rpc service start service=hadoop-yarn-nodemanager --with-identity mncars005
manager> mco rpc service start service=hadoop-yarn-nodemanager --with-identity mncars006


manager> mco rpc deploop execute cmd='source /etc/profile.d/java.sh && sudo -E -u hdfs hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-client-jobclient-2.2.0.jar' --with-identity=mncars001




