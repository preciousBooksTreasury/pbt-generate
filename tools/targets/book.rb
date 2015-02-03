
def generatePrintBook(book, template, target)
    data = readAllBooks(book)
    metadata,_ = getMetaData(book)
    metadata.merge!(target)

    metadata['text'] = data
    metadata['format_css'] = $home + "/style/format/#{metadata['format']}.css"
    metadata['font_css'] = $home + "/style/font/#{metadata['font']}.css"
    metadata['language_css'] = $home + "/style/language/#{metadata['language']}.css"
    metadata['base'] = book
   
    tmpl = IO.read(template)
    out_html = parseTemplate(tmpl, metadata)
    fileName = genFileName(metadata, target)+ "-print"
    
    #write html
    aFile = File.new(fileName + ".html", "w")
    aFile.syswrite(out_html)
    
    #generate book
    system("pandoc --template=\"\"--toc --latex-engine=xelatex -s \"#{fileName}.html\" -o \"#{fileName}.pdf\"")
    puts "generated #{fileName}.pdf"
end
