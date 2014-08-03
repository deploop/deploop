fact = 'category'
value = 'serving'
filename="deploop_#{fact}.rb"

$setcode = ''

# If file exits we have to get
# the setcode line in order to
# build a new line with the new
# value append.
if File.file? filename
    File.foreach(filename) {|x| 
        if x.include? 'setcode'
            if x.include? value
                exit
            end
            a = (x.delete! '\"').lstrip
            a.slice! "setcode echo"
            $setcode = a.lstrip
            break
        end
    }
    value = $setcode.chomp! + " " + value
    value = value.gsub(/\r\n?/, "\n")
end

puts "adding: #{value}"

# Using the setcode line appened with
# the new value, rewrite again the fact file.
File.open(filename,"w+") {|f|
    f.puts "Facter.add(:deploop_#{fact}) do"
    f.puts "\tsetcode \"echo #{value}\""
    f.puts 'end'
    f.close
}

