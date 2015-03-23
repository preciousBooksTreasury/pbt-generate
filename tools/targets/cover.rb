require_relative 'epubli_size.rb'
require_relative 'lulu_size.rb'
def generateCover(book, metadata, target, template)
    if(not metadata.has_key? 'img')
        return
    end
    
    # set metadata variables
    css_file_local = genFileName(metadata, target)+"-cover.css"
    css_file_global = book + '/'+metadata['cover']
    if(File.exists? css_file_local)
        metadata['css'] =  css_file_local
    end
    if(File.exists? css_file_global)
        metadata['css'] =  css_file_global
    end
    return if metadata['img'] == {}
    metadata['img'] = $home +"/cover/" +  metadata['img'];
    metadata['base'] = book
    
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
    system("wkhtmltoimage \"#{f}.html\" \"#{f}.jpg\"")
    
end

def getPDFPagecount(file)
    ret = `pdfinfo "#{file}" | grep ^Pages:`.strip
    ret.split(':')[1].strip
end

def generateCoverFile(book, metadata, target)
    pdf_file = genFileName(metadata, target)+"-print.pdf"
    pagecount = getPDFPagecount(pdf_file)
    if(target['printerName'] == "epubli") 
        size = getEpubliSize(target['papersize'], target['binding'], pagecount)
    elsif(target['printerName'] == "lulu") 
        size = LuluCover.getSize(target['papersize'], target['binding'], pagecount)
    else
        return
    end
    css_file = genFileName(metadata, target)+"-cover.scss"
    File.write(css_file, 
"@import 'style/_tools.scss';
@import 'style/_coverConfig.scss';
$width: #{size[0]};
$height: #{size[1]};
$back: #{size[2]};
$begin: #{size[3]};
$padding: #{size[4]};
@import 'style/_cover.scss';")
    
    #compile
    `#{$compass} compile "#{css_file}"`
end
