
def generatePandocPDF(book, metadata, target)
    papersizes = YAML.load_file("#{$home}/config/papersizes.yml")
    metadata['base'] = book
    size = papersizes[metadata['papersize']]
    
    fileName = genFileName(metadata, target)+ "-print"
    co = ""
    metadata['classoptions'].each do |x|
        co += "-V 'classoption:#{x}' "
    end
    
    size_param = ""
    geometry = ""
    if(size.has_key? 'width') 
        size_param = "-V 'geometry:paperwidth=#{size['width']}' \
        -V 'geometry:paperheight=#{size['height']}'"
        
        geometry = "-V 'geometry:top=#{size['top']}, bottom=#{size['bottom']}, left=#{size['left']}, right=#{size['right']}'"
    elsif(size.has_key? 'alias')
        size_param = "-V 'papersize:#{size['alias']}'"
        
        geometry = "-V geometry:'vmarginratio={100:161},heightrounded'"
     
    end
    #        -V 'fontfamily:#{metadata['font']}' \
    #        -V 'mainfont:Times New Roman' \

    #generate book
    a = "pandoc \
        #{size_param} \
        #{geometry} \
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
        #{co} \
        --template='pandoc/#{metadata['pandocTemplate']}' \
        --toc \
        --latex-engine=xelatex \
        -s '#{book}/data.markdown' \
        -o '#{fileName}.#{metadata['fileType']}'"
    puts a.squeeze(' ')
    system(a)
    if($?.success?)
        puts "generated #{fileName}.pdf"
    else
        puts "failed #{fileName}"
    end
end


def generatePandocEPUB(book, metadata, target)
    metadata['base'] = book
    
    fileName = genFileName(metadata, target)+ "-print"
    
    #generate book
    a = "pandoc \
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
        --template='pandoc/#{metadata['pandocTemplate']}' \
        --toc \
        -s '#{book}/data.markdown' \
        -o '#{fileName}.#{metadata['fileType']}'"
    puts a
    system(a)
    if($?.success?)
        puts "generated #{fileName}.epub"
    else
        puts "failed #{fileName}"
    end
end

