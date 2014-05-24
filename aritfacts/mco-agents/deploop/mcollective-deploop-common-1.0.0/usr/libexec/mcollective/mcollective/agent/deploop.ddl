metadata :name        => "Deploop Facter Deployer",
         :description => "Key tool for deploy Deploop Facters in new servers",
         :author      => "Javi Roman <javiroman@redoop.org",
         :license     => "APL-2.0",
         :version     => "0.0.1",
         :url         => "https://github.com/deploop",
         :timeout     => 10

action "create_fact", :description => "Create Deploop Facter in Agent" do
    display :always

    input :fact,
          :prompt      => "FACT",
          :description => "The FACT name to create",
          :type        => :string,
          :validation  => '^[a-zA-Z\-_\d\.:\/]+$',
          :optional    => false,
          :maxlength   => 100

    input :value,
          :prompt      => "VALUE",
          :description => "The VALUE to insert in the FACT",
          :type        => :string,
          :validation  => '^[a-zA-Z\-_\d\s\.:\/]+$',
          :optional    => false,
          :maxlength   => 100

   output "response_code",
          :description => "The creation file success",
          :display_as  => "Response code"
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



