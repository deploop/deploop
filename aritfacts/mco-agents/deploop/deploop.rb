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

	$setcode = ''

	# If file exits we have to get
	# the setcode line in order to
	# build a new line with the new
	# value append.
	if File.file? fileout
            Log.info("deploop facter append: %s" % fileout)
	    File.foreach(fileout) {|x|
		if x.include? 'setcode'
		    a = (x.delete! '\"').lstrip
		    a.slice! "setcode echo"
		    $setcode = a.lstrip
		    break
		end
	    }
	    if $setcode.include? value
		value = $setcode.chomp!
	    else
	    	value = $setcode.chomp! + " " + value
	    end
	end

	# Using the setcode line appened with
	# the new value, rewrite again the fact file.
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
        conffile = '/etc/puppet/puppet.conf'

        Dir.mkdir('/var/lib/puppet/facts.d/') unless File.exists?('/var/lib/puppet/facts.d/')

        # Purge file for new entries if the file was deplooyed.
        string = IO.read(conffile)
        string = string.gsub!(/^pluginsync.*/m, '')
        if !string.nil?
          File.open(conffile,"w") { |f| f << string }
        end

        # writes new entries at tail.
        File.open(conffile, "a+") {|f| 
          f.puts(disableplugin)
          f.puts(factpath) 
          f.puts(env)
        }

        reply['response_code'] = 0
      end

      action "execute" do
        validate :cmd, String

        out = []
        err = ""

        begin
          status = run("#{request[:cmd]}", :stdout => out, :stderr => err, :chomp => true)
        rescue Exception => e
          reply.fail e.to_s
        end

        reply[:exitcode] = status
        reply[:stdout] = out.join(" ")
        reply[:stderr] = err
        reply.fail err if status != 0
      end
    end
  end
end

