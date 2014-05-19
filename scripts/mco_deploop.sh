# Example for copy new facts in server node. We have to take into account [1] and [2]
# [1] http://docs.puppetlabs.com/mcollective/reference/plugins/facts.html
# [2] https://github.com/puppetlabs/marionette-collective/tree/master/plugins/mcollective/facts

#DEPLOOP_FACT="deploop_role.rb"
#DEPLOOP_FACT="deploop_category.rb"
#DEPLOOP_FACT="deploop_collection.rb"
DEPLOOP_FACT="deploop_entity.rb"

# mco rpc deploop puppet_environment env=production
# mco rpc deploop puppet_environment env=preproduction
# mco rpc deploop puppet_environment env=test

# This match with the Puppet environment configuration
# /etc/puppet/environments/production
#                          preproduction
#                          test

mco rpc deploop download_fact url="http://openbus-deploop:8080/$DEPLOOP_FACT"

# The file must be go to /var/lib/puppet/lib/facter/ and update with 
# facter -p -y > /etc/mcollective/facts.yaml


# Check for the new Deploop Fact:

mco ping --with-fact "${DEPLOOP_FACT%.rb}=/.*/"
mco inventory openbus-nn1 | grep deploop | grep =
