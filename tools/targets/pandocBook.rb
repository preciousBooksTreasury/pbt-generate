
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
    if(size.has_key? 'width') 
        size_param = "-V 'geometry:paperwidth=#{size['width']}' \
        -V 'geometry:paperheight=#{size['height']}'"
    elsif(size.has_key? 'alias')
        size_param = "-V 'papersize:#{size['alias']}'";
    end
    
    #generate book
    a = "pandoc \
        #{size_param} \
        -V 'fontsize:#{metadata['fontsize']}' \
        -V 'author:#{metadata['author']}' \
        -V 'title:#{metadata['title']}' \
        -V 'subtitle:#{metadata['subtitle']}' \
        -V 'book-format-string:#{metadata['format']}' \
        -V 'gen-time:#{metadata['gentime']}' \
        -V 'isbn:#{metadata['isbn']}' \
        -V 'printed-by:#{metadata['print']}' \
        -V 'copyright:#{metadata['license']}' \
        -V 'original-title:#{metadata['originalTitle']}' \
        -V 'original-author:#{metadata['originalAuthor']}' \
        -V 'lang:#{metadata['language']}' \
        -V 'fontfamily:#{metadata['font']}' \
        -V 'documentclass:memoir' \
        #{co} \
        --template='pandoc/#{metadata['pandocTemplate']}' \
        --toc \
        --latex-engine=xelatex \
        -s '#{book}/data.markdown' \
        -o '#{fileName}.#{metadata['fileType']}'"
    puts a
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
        -V 'author:#{metadata['author']}' \
        -V 'title:#{metadata['title']}' \
        -V 'subtitle:#{metadata['subtitle']}' \
        -V 'book-format-string:#{metadata['format']}' \
        -V 'gen-time:#{metadata['gentime']}' \
        -V 'isbn:#{metadata['isbn']}' \
        -V 'printed-by:#{metadata['print']}' \
        -V 'copyright:#{metadata['license']}' \
        -V 'original-title:#{metadata['originalTitle']}' \
        -V 'original-author:#{metadata['originalAuthor']}' \
        -V 'lang:#{metadata['language']}' \
        --template='pandoc/#{metadata['pandocTemplate']}' \
        --toc \
        -s '#{book}/data.markdown' \
        -o '#{fileName}.#{metadata['fileType']}'"
    puts a
    system(a)
    if($?.success?)
        puts "generated #{fileName}.pdf"
    else
        puts "failed #{fileName}"
    end
end

