metadata :name        => "Deploop Facter Deployer",
         :description => "Key tool for deploy Deploop Facters in new servers",
         :author      => "Javi Roman <javiroman@redoop.org",
         :license     => "APL-2.0",
         :version     => "0.0.1",
         :url         => "https://github.com/deploop",
         :timeout     => 10

action "download_fact", :description => "Download Deploop Facter from URL" do
    display :always

    input :url,
          :prompt      => "URL",
          :description => "The URL to download",
          :type        => :string,
          :validation  => '^[a-zA-Z\-_\d\.:\/]+$',
          :optional    => false,
          :maxlength   => 100

   output "response_code",
          :description => "last received HTTP or FTP code",
          :display_as  => "Response code"

   output "downloaded_content_length",
          :description => "Content-length of the download.",
          :display_as  => "Content-length"
end

action "puppet_environment", :description => "Set Puppuet Agent environment" do
    display :always

    input :env,
          :prompt      => "ENVIRONMENT",
          :description => "The environment to set in the Puppet Agent",
          :type        => :string,
          :validation  => '^[a-zA-Z\-_\d\.:\/]+$',
          :optional    => false,
          :maxlength   => 50 

    output "response_code",
          :description => "puppet.conf write return code",
          :display_as  => "Response code"
end



