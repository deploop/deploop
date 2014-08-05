 sed -i '/factpath/d' /etc/puppet/puppet.conf
 sed -i '/pluginsync/d' /etc/puppet/puppet.conf
 sed -i '/environment/d' /etc/puppet/puppet.conf
 rm /etc/mcollective/facts.yaml -f
 rm -f /var/lib/puppet/facts.d/deploop*
 rm -fr /var/lib/zookeeper/* && rm -fr /data/*/*
 for i in $(seq 1 5); do mkdir -p /data/$i; done

