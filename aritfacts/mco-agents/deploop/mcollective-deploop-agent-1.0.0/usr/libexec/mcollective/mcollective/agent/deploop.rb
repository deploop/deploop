# vim: autoindent tabstop=2 shiftwidth=2 expandtab softtabstop=2 filetype=ruby
module MCollective
  module Agent
    class Deploop<RPC::Agent

      action 'download_fact' do
        validate :url, String

        url = request[:url]
        Log.info("url passed: %s" % url)

        require 'rubygems'
        require 'curb'
	      require 'facter'
    	  require 'yaml'

        facterpath='/var/lib/puppet/facts.d'

        filename=url.split('/').last
        fileout = "#{facterpath}/#{filename}"
        Log.info("deploop facter location: %s" % fileout)

        c = Curl::Easy.download(url, filename=fileout)

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

        reply['response_code'] = c.response_code 
        reply['downloaded_content_length'] = c.downloaded_content_length 
      end
    end
  end
end

