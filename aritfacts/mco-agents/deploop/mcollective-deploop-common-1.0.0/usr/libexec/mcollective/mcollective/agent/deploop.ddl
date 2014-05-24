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

["execute"].each do |act|
  action act, :description => "#{act.capitalize} a command" do
    display :always

    input :cmd,
          :prompt      => "Command",
          :description => "The name of the command to #{act}",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => false,
          :maxlength   => 300

    output :output,
           :description => "Command Output",
           :display_as  => "Output"

    output :error,
           :description => "Command Error",
           :display_as  => "Error"

    output :exitcode,
           :description => "Exit code of the shell process",
           :display_as  => "Exit Code"
  end
end



