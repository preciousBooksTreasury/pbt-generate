
def match(l)
    #puts "#{l}-- #{l.end_with? "."} or #{l.end_with? "\""}"
    l.end_with? ".\n" or l.end_with? "\"\n"
end

    
def main
    out = ""

    i = false;
    File.open(ARGV[0]).each do |line|
        if(line.start_with? "<blockquote>")
            i = true
            out += "\n</p>\n"
        end
        out += line
        if(i == false) 
            if(match(line)) 
                out += "</p>\n<p>\n"
            end
        end
       
        
        if(line.start_with? "</blockquote>")
            i = false
            out += "\n<p>\n"
        end
    end
    puts out
end

main()