
def is_heading(x)
    x.start_with? "="
end

    
def main
    out = ""

    File.open(ARGV[0]).each do |line|
        line.strip!
        next if line == ""
        next if line.start_with? "~"
        
        if(is_heading(line))
            line.gsub! "=", ""
            if(out != "")
                out += "</div>\n";
            end
            out += "<div class=\"chapter\">\n"
            out += "<h1 class=\"caption\">#{line}</h1>\n"
        else
            out += "<p>#{line}</p>\n"
        end
        
    end
    out += "</div>"
    i = 0
    while(out["**"] != nil)
        if(i % 2 == 0)
            out["**"] = "<b>"
        else
            out ["**"] = "</b>"
        end
        i += 1
    end
    out.gsub! "\\", "<br />"
        
    puts out
end

main()