def parseTemplate( templateStr, values )
    templateStr.gsub( /:::(.*?):::/ ) { 
        if(values.has_key? $1) 
            values[$1].to_str 
        else 
            "" 
        end
    }
end

class Dir
    def self.each_recursive(path, &block)
        Dir.foreach(path) do |fname|
            if fname == "." || fname == ".."
                #ignore
            else
                block.call(path + "/", fname)

                #recurse if possible
                if File.directory?(path + "/" + fname)
                    each_recursive(path+"/"+fname, &block)
                end
            end
        end
    end
end


def genFileName(metadata, target)
    genFolderName(metadata) +'/'+ metadata['latinTitle'] + "-" + target['name']
end

def genFolderName(metadata)
    a = metadata['author']
    if metadata['originalAuthor']
        a = metadata['originalAuthor']
    end
    path = $outputPath + '/' + a
    FileUtils.mkpath path
    return path
end

def compassCompile()
    a = `ls /usr/bin | grep compass`
    `#{a} compile '#{$home}'`
end