# vim: autoindent tabstop=2 shiftwidth=2 expandtab softtabstop=2 filetype=ruby
module MCollective
  module Agent
    class Deploop<RPC::Agent

      action 'create_fact' do
        validate :fact, String
        validate :value, String

        fact = request[:fact]
        value = request[:value]
        Log.info("fact passed: %s" % fact)
        Log.info("with values: %s" % value)

	      require 'facter'
    	  require 'yaml'

        facterpath='/var/lib/puppet/facts.d'

        filename="deploop_#{fact}.rb"
        fileout = "#{facterpath}/#{filename}"

        File.open(fileout,"w+") {|f|
          f.puts "Facter.add(:deploop_#{fact}) do"
          f.puts "\tsetcode \"echo #{value}\""
          f.puts 'end'
          f.close
        }

        Log.info("deploop facter location: %s" % fileout)

        config = MCollective::Config.instance
	      yamlfile = config.pluginconf["yaml"]
        Log.info("YAML file to update: %s" % yamlfile)

	      rejected_facts = ['sshdsakey', 'sshrsakey']

	      Facter.clear
	      Facter.search(facterpath)
	      Facter.loadfacts
	      Facter.flush
	
	      facts = Facter.to_hash.reject { |k,v| rejected_facts.include? k }

	      File.open(yamlfile, "w") { |fh| 
	        fh.write facts.to_yaml
	        fh.close
        }

        reply['response_code'] = 0
      end

      action 'puppet_environment' do
        validate :env, String

        env = request[:env]
        env = "environment=#{env}"
        factpath='factpath=/var/lib/puppet/facts.d/'
        disableplugin='pluginsync=false'

        File.open("/etc/puppet/puppet.conf","a+") {|f| 
          f.puts(disableplugin) 
          f.puts(factpath) 
          f.puts(env)
        }

        reply['response_code'] = 0
      end
    end
  end
end

