metadata :name        => "curl - transfer a URL",
         :description => "Tool to transfer data from or to a server, using URLs",
         :author      => "Javi Roman based on Louis Coilliot code",
         :license     => "",
         :version     => "0.1",
         :url         => "",
         :timeout     => 10

action "download", :description => "Download URL" do
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

