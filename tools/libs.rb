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
    if metadata.has_key? 'originalAuthor' and metadata['originalAuthor'] != ""
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


def getLanguageName(book)
    a = book.split('/')[-1]
    if a == "en"
        return "english"
    elsif a == "de"
        return "german"
    elsif a == "ru"
        return "russian"
    end
end

def getTargets(metadata)
    target_sets = YAML.load_file("#{$home}/config/default-targets.yml")
    targets = Hash.new()
    targets_raw = metadata['targets']
    targets_raw.each do |t|
        if t.is_a? String
            target_sets.each do |s|
                if s['name'] == t
                    targets = s['targets']
                end
            end
        end
    end
    return targets
end

def getMetaData(book)
    metadata = YAML.load_file(book + "/metadata.yml")
    
    metadata['language'] = getLanguageName(book)
    targets = getTargets(metadata);
  
    metadata['gentime'] = Time.now.to_s
    return metadata,targets
end

def prepareMetadata(metadata)
    if(not metadata.has_key? 'font')
        metadata['font'] = 'lmodern'
        metadata['mainfont'] = 'CMU Serif'
        metadata['sansfont'] = 'CMU Sans Serif'
        metadata['monofont'] = 'CMU Typewriter Text'
    end
    if(not metadata.has_key? 'classoptions')
        metadata['classoptions'] = ['twoside','openright','final']
    else
        if(metadata['classoptions'].is_a?(String)) 
            metadata['classoptions'] =  metadata['classoptions'].split(',')
        end
    end
    return metadata
end


def prepareUniverse()
    Dir.mkdir $outputPath if not Dir.exists? $outputPath
end

def readAllBooks(book)
    data = IO.read("#{book}/data.html")
    i = 1
    while File.exists?("#{book}/data#{i}.html")
        data += IO.read("#{book}/data#{i}.html")
        i += 1
    end
    return data
end

def sanitizeBash(string)
    return nil if string == nil
    return string.gsub("'","")
end
    
