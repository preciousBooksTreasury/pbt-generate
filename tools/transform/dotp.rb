#encoding: utf-8
def main
    en = "</p>\r\n"
    ok_end = [".","?","!","\"","”"]
    f = IO.read(ARGV[0])
    f = f.gsub(/([^\.\?\!\"])<\/p>\r\n<p>/) do 
        $1 + "\r\n"
    end
    puts f

end

main()
