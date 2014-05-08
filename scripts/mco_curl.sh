# Example for copy new facts in server node. We have to take into account [1] and [2]
# [1] http://docs.puppetlabs.com/mcollective/reference/plugins/facts.html
# [2] https://github.com/puppetlabs/marionette-collective/tree/master/plugins/mcollective/facts

mco rpc curb download url="http://openbus-deploop:8080/deploop_collective.rb"

# The file must be go to /var/lib/puppet/lib/facter/ and update with 
# facter -p -y > /etc/mcollective/facts.yaml
