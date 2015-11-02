require_relative 'epubli_size.rb'
require_relative 'lulu_size.rb'
def generateCover(book, metadata, target, template)
    if(not metadata.has_key? 'img')
        return
    end
    dir = File.dirname(book)
    # set metadata variables
    css_file_local = genFileName(metadata, target)+"-cover.css"
    css_file_global = dir + '/'+metadata['cover']
    if(File.exists? css_file_local)
        metadata['css'] =  css_file_local
    end
    if(File.exists? css_file_global)
        metadata['css'] =  css_file_global
    end
    return if metadata['img'] == {} or metadata['img'] == nil
    metadata['img'] = $cover + '/'+ metadata['img'];
    metadata['base'] = dir
    
    if(target.has_key? 'isbn')
        info_msg "has isbn #{target['isbn']}"
        metadata['isbn-pic'] = "<img id='isbn' src='#{$home}/isbn/#{target['isbn']}.png' />"
    end
    
    tmpl = IO.read(template) # read template file
    out = parseTemplate(tmpl, metadata) # apply metdata variables
    
    f = genFileName(metadata, target) + "-cover" # new filename
    
    #write html
    aFile = File.new(f+".html", "w")
    aFile.syswrite(out)
    
    #generate book
    puts "filename ===="  + f
    system("wkhtmltoimage --enable-javascript --javascript-delay 100 \"#{f}.html\" \"#{f}.jpg\"")
    
end

def generateCoverSmall(metadata, result)
     if(not metadata.has_key? 'img')
        return
    end
    
    return if metadata['img'] == {}
    metadata['img'] = $cover + '/' + metadata['img'];
    metadata['css'] = "#{$home}/style/cover-small.css"
    
    tmpl = IO.read("#{$home}/template/cover-small.html") # read template file
    out = parseTemplate(tmpl, metadata) # apply metdata variables
    f = genFileNameGlobal(metadata) + "-cover-small" # new filename
    
    #write html
    aFile = File.new(f+".html", "w")
    aFile.syswrite(out)
    #generate book
    system("wkhtmltoimage --crop-h 210 --crop-w 148 \"#{f}.html\" \"#{result}\"")
end
    
def getPDFPagecount(file)
    ret = `pdfinfo "#{file}" | grep ^Pages:`.strip
    ret.split(':')[1].strip
end

def generateCoverFile(book, metadata, target)
   if(not metadata.has_key? 'img')
        return
    end
    pdf_file = genFileName(metadata, target)+"."+metadata['fileType']
    pagecount = getPDFPagecount(pdf_file)
    if(target['printerName'] == "epubli") 
        size = getEpubliSize(target['papersize'], target['binding'], pagecount)
    elsif(target['printerName'] == "lulu") 
        size = LuluCover.getSize(target['papersize'], target['binding'], pagecount)
    else
        return
    end
    
    # big cover file
    scss_file = genFileName(metadata, target)+"-cover.scss"
    File.write(scss_file, 
"@import 'style/_tools.scss';
@import 'style/_coverConfig.scss';
$width: #{size[0]};
$height: #{size[1]};
$back: #{size[2]};
$begin: #{size[3]};
$padding: #{size[4]};
@import 'style/_cover.scss';")
    
    compass_compile(scss_file)
end
