
def  generatePandocPrintBook(book, template, pandocTemplate, target)
    metadata,_ = getMetaData(book)
    metadata.merge!(target)
    papersizes = YAML.load_file("#{$home}/config/papersizes.yml")

    metadata['format_css'] = $home + "/style/format/#{metadata['format']}.css"
    metadata['font_css'] = $home + "/style/font/#{metadata['font']}.css"
    metadata['language_css'] = $home + "/style/language/#{metadata['language']}.css"
    metadata['base'] = book
    size = papersizes[metadata['papersize']]
    
    fileName = genFileName(metadata, target)+ "-print"
    
    #generate book
    a = "pandoc \
        -V 'geometry:paperwidth=#{size['width']}' \
        -V 'geometry:paperheight=#{size['height']}' \
        -V 'fontsize:#{metadata['fontsize']}' \
        -V 'author:#{metadata['author']}' \
        -V 'title:#{metadata['title']}' \
        -V 'subtitle:#{metadata['subtitle']}' \
        -V 'book-format-string:#{metadata['format']}' \
        -V 'gen-time:#{metadata['gentime']}' \
        -V 'isbn:#{metadata['isbn']}' \
        -V 'printed-by:#{metadata['print']}' \
        -V 'original-title:#{metadata['originalTitle']}' \
        -V 'original-author:#{metadata['originalAuthor']}' \
        -V 'documentclass:memoir' \
        --template='#{pandocTemplate}' \
        --toc \
        --latex-engine=xelatex \
        -s '#{book}/data.markdown' \
        -o '#{fileName}.pdf'"
    puts a
    system(a)
    if($?.success?)
        puts "generated #{fileName}.pdf"
    else
        puts "#{fileName} failed"
    end
    
    #File.delete(fileName + ".html") if($options[:cleanUp])
end
