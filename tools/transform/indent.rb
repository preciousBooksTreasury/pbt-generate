def match(l)
    l.start_with? "   "
end
def num(x)
    Integer(x) rescue false
end
$i = false;
File.open( ARGV[0] ) do |f|
  loop do
    break if not line = f.gets
    
    if(line.strip.start_with? "End Notes")
        puts line;
        loop do 
            break if not number = f.gets
            if num(number.strip)
                ref = f.gets
                puts "<div class=\"ref_content\"> <span>#{number.strip}</span> #{ref.strip}</div>";
            else
                puts number
                break;
            end
        end
    else
        if(match line) 
            puts "</p>\n<p>"
        end
    
        puts line
    end
    
  
  end
end

File.open(ARGV[0]).each do |line|
    
   
end