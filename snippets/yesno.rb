def confirm_action?
  cont = true
  while cont
    print "are you sure? [y/n]: "
    case gets.strip
      when 'Y', 'y', 'j', 'J', 'yes' 
        cont = false
      when /\A[nN]o?\Z/
        exit
    end
  end
end

confirm_action?

puts "we follow palying"
