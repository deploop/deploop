module MCollective
    module Agent
        class Deploop<RPC::Agent

            action "download" do
                validate :url, String
                url = request[:url]
		Log.info("url passed: %s" % url)

                require 'curb'

                localpath='/tmp'
                filename=url.split('/').last
                fileout = "#{localpath}/#{filename}"
		Log.info("output filename: %s" % fileout)

                c = Curl::Easy.download(url,filename=fileout)

                reply["response_code"] = c.response_code 
                reply["downloaded_content_length"] = c.downloaded_content_length 
            end

        end
    end
end
