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
    if metadata.has_key? 'latinAuthor' and metadata['latinAuthor'] != ""
        a = metadata['latinAuthor']
    end
    if metadata.has_key? 'originalAuthor' and metadata['originalAuthor'] != ""
        a = metadata['originalAuthor']
    end
    path = $outputPath + '/' + a
    FileUtils.mkpath path
    return path
end

def compassCompile()
    $compass = `ls /usr/bin | grep compass`.strip
    `#{$compass} compile '#{$home}'`
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
def getTargetByName(name)
    targets = YAML.load_file("#{$home}/config/default-targets.yml")
    if(not targets.has_key? name)
      puts "Target '#{name}' not found"
      return nil
    end
    t = targets[name]
    t['name'] = name
    return t
end
def getTargetSetByName(name)
    target_sets = YAML.load_file("#{$home}/config/default-targetsets.yml")
    if(not target_sets.has_key? name)
      puts "TargetSet #{name} not found"
      return nil
    end
    target_set = target_sets[name]
    targets = {}
    target_set.each do |target_name|
      targets[target_name] = getTargetByName(target_name)
    end
    return targets
end

def getTargets(metadata)
    targets = {}
    
    if(metadata.has_key? 'target-sets')
        metadata['target-sets'].each do |t|
            targets.merge!(getTargetSetByName(t))
        end
    end
    
    if(metadata.has_key? 'targets')
        metadata['targets'].each do |name, content|
          if(not targets.has_key? name)
            targets[name] = getTargetByName(name)
          end
          targets[name] = targets[name].merge(content)
        end
    end
    return targets
end

def getMetaData(book)
    metadata = YAML.load_file(book + "/metadata.yml")
    
    metadata['language'] = getLanguageName(book)
    metadata['gentime'] = Time.now.to_s
    
    targets = getTargets(metadata);

    return metadata, targets
end

def prepareMetadata(metadata)
    if(not metadata.has_key? 'font')
        metadata['font'] = 'lmodern'
        metadata['mainfont'] = 'CMU Serif'
        metadata['sansfont'] = 'CMU Sans Serif'
        metadata['monofont'] = 'CMU Typewriter Text'
    end
    if(not metadata.has_key? 'classoptions')
        metadata['classoptions'] = ['twoside','openany','final']
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
    
def error_msg(msg)
    puts "\e[91mERROR\e[0m #{msg}"
    exit 1
end

def info_msg(msg)
    puts "\e[93mINFO\e[0m #{msg}"
end

def ok_msg(msg)
    puts "\e[34mOK\e[0m #{msg}"
end