
def generatePandocPDF(book, metadata, target)
    papersizes = YAML.load_file("#{$home}/config/papersizes.yml")
    metadata['base'] = book
    size = papersizes[metadata['papersize']]
    
    fileName = genFileName(metadata, target)
    co = ""
    metadata['classoptions'].each do |x|
        co += "-V 'classoption:#{x}' "
    end
    
    size_param = ""
    geometry = ""
    if(size.has_key? 'width') 
        size_param = "-V 'geometry:paperwidth=#{size['width']}' \
        -V 'geometry:paperheight=#{size['height']}'"
    elsif(size.has_key? 'alias')
        size_param = "-V 'papersize:#{size['alias']}'"
    end
    geometry = ""
    
    if(size.has_key? 'left') 
        geometry += "left=#{size['left']},"
    end
    if(size.has_key? 'right') 
        geometry += "right=#{size['right']},"
    end
    if(size.has_key? 'top') 
        geometry += "top=#{size['top']},"
    end
    if(size.has_key? 'bottom') 
        geometry += "bottom=#{size['bottom']},"
    end
    if(size.has_key? 'geometryoptions') 
        geometry += size['geometryoptions']
    end

    #        -V 'fontfamily:#{metadata['font']}' \
    #        -V 'mainfont:Times New Roman' \

    #generate book
    a = "cd '#{File.dirname(book)}' && pandoc \
        #{size_param} \
        -V 'geometry:#{geometry}' \
        -V 'fontsize:#{metadata['fontsize']}' \
        -V 'author:#{metadata['author']}' \
        -V 'title:#{sanitizeBash(metadata['title'])}' \
        -V 'subtitle:#{sanitizeBash(metadata['subtitle'])}' \
        -V 'book-format-string:#{metadata['format']}' \
        -V 'gen-time:#{metadata['gentime']}' \
        -V 'isbn:#{metadata['isbn']}' \
        -V 'printed-by:#{metadata['print']}' \
        -V 'copyright:#{metadata['license']}' \
        -V 'original-title:#{sanitizeBash(metadata['originalTitle'])}' \
        -V 'original-author:#{sanitizeBash(metadata['originalAuthor'])}' \
        -V 'lang:#{metadata['language']}' \
        -V 'mainfont:#{metadata['mainfont']}' \
        -V 'sansfont:#{metadata['sansfont']}' \
        -V 'monofont:#{metadata['monofont']}' \
        -V 'documentclass:memoir' \
        --no-tex-ligatures \
        #{co} \
        --template='#{$home}/pandoc/#{metadata['pandocTemplate']}' \
        --toc \
        --latex-engine=xelatex \
        -s '#{book}' \
        -o '#{fileName}.#{metadata['fileType']}'"
    puts a.squeeze(' ')
    system(a)
    if($?.success?)
        puts "generated #{fileName}.pdf"
    else
        puts "failed #{fileName}"
    end
    return fileName+"."+metadata['fileType']
end


def generatePandocEPUB(book, metadata, target)
    metadata['base'] = book
    
    fileName = genFileName(metadata, target)
    
    #generate book
    a = "cd '#{File.dirname(book)}' && pandoc \
        -V 'author:#{sanitizeBash(metadata['author'])}' \
        -V 'title:#{sanitizeBash(metadata['title'])})' \
        -V 'subtitle:#{sanitizeBash(metadata['subtitle'])}' \
        -V 'book-format-string:#{metadata['format']}' \
        -V 'gen-time:#{metadata['gentime']}' \
        -V 'isbn:#{metadata['isbn']}' \
        -V 'printed-by:#{sanitizeBash(metadata['print'])}' \
        -V 'copyright:#{sanitizeBash(metadata['license'])}' \
        -V 'original-title:#{sanitizeBash(metadata['originalTitle'])}' \
        -V 'original-author:#{sanitizeBash(metadata['originalAuthor'])}' \
        -V 'lang:#{metadata['language']}' \
        --template='#{$home}/pandoc/#{metadata['pandocTemplate']}' \
        --toc \
        -s '#{book}' \
        -o '#{fileName}.#{metadata['fileType']}'"
    puts a
    system(a)
    if($?.success?)
        puts "generated #{fileName}.epub"
    else
        puts "failed #{fileName}"
    end
end

