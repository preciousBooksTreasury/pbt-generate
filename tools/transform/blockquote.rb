
def match(l)
    l.start_with? "        "
end
def main
    out = ""
    prevline = ""
    File.open(ARGV[0]).each do |line|
        c = line.clone
        if(match(line) and not match(prevline))
            out += "\n<blockquote>\n"
        end
        if(not match(line) and match(prevline))
            out += "</blockquote>\n"
        end
        if(match(line))
            line["        "] = "";
        end
        out += line
        prevline = c
    end
    puts out
end

main()