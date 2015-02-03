
def generateCover(book, template, t)
    metadata,_ = getMetaData(book)
    metadata.merge!(t)
    
    #generate toc
    if(not metadata.has_key? 'img')
        return
    end
    
    # set metadata variables
    metadata['css'] = book + '/'+metadata['cover']
    return if metadata['img'] == {}
    metadata['img'] = $home +"/cover/" +  metadata['img'];
    metadata['base'] = book
    if(metadata.has_key? 'isbn')
        metadata['isbn-pic'] = "<img id=\"isbn\" src=\""+metadata['base']+"/isbn.png\" />"
    end
    
    tmpl = IO.read(template)#read template file
    out = parseTemplate(tmpl, metadata) # apply metdata variables
    
    f = genFileName(metadata, t) + "-cover" # new filename
    
    #write html
    aFile = File.new(f+".html", "w")
    aFile.syswrite(out)
    
    #generate book
    puts "filename ===="  + f
    system("wkhtmltoimage \"#{f}.html\" \"#{f}.jpg\"")
    
end
