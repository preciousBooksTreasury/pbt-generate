require 'zip'

def generateEPub(book, template, target)
    fileNames = []
    uid = Time.now.to_i.to_s
    tmpl = IO.read(template)
    
    #get filenames
    chapter = Hash.new
    chapter[:id] = 0
    chapter[:name] = "data.html"
    fileNames << chapter
    i = 1
    while File.exists?("#{book}/data{i}.html")
        chapter = Hash.new
        chapter[:id] = i
        chapter[:name] = "data#{i}.html"
        fileNames << chapter
        i += 1
    end
    
    #read metadata
    metadata,_ = getMetaData(book)
    metadata.merge!(target)
    
    
    #create dir with all the content
    epub_dir = genFileName(metadata, target) + "-epub"
    epub_filename = genFileName(metadata, target) + ".epub"

    #create various required files and directorys
    #0. directorys
    FileUtils.mkdir_p(epub_dir + "/content")
    FileUtils.mkdir_p(epub_dir + "/META-INF")

    #1. manifest
    mimetype = File.open(epub_dir + "/mimetype", "w")
    mimetype << "application/epub+zip"
    mimetype.close()

    #2.content.opf
    opfheader = <<-EOS
<?xml version='1.0' encoding='utf-8'?>
    <package xmlns="http://www.idpf.org/2007/opf" unique-identifier="uuid" version="2.0">
    <metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" 
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:opf="http://www.idpf.org/2007/opf">
    <dc:identifier id="uuid">#{uid}</dc:identifier>
    <dc:title>#{metadata['title']}</dc:title>
    <dc:creator opf:role="aut">#{metadata['author']}</dc:creator>
    <dc:language>#{metadata['lang']}</dc:language>
    <dc:date opf:event="release">#{metadata['year']}</dc:date>
    </metadata>

    <manifest>
    <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml" />
    EOS
    
    items = fileNames.inject("") { |s, c|
        s + "<item id=\"data#{c[:id]}\" href=\"content/#{c[:name]}\" 
media-type=\"application/xhtml+xml\"/>\n"
       } + "</manifest>"

    spine = fileNames.inject("<spine toc=\"ncx\">\n") { |s, c|
            s + "<itemref idref=\"data#{c[:id]}\" />\n"
    } + "</spine>\n\n"

    opf = File.open(epub_dir  + "/content.opf", "w")
    opf << opfheader
    opf << items
    opf << spine
    opf << "</package>"
    opf.close()
    
     #3. meta-inf/container.xml
    container = File.open(epub_dir  + "/META-INF/container.xml", "w")
    container << '<?xml version="1.0" encoding="utf-8"?><container version="1.0" 
xmlns="urn:oasis:names:tc:opendocument:xmlns:container"><rootfiles><rootfile full-path="content.opf" 
media-type="application/oebps-package+xml"/></rootfiles></container>'
    container.close()

    #4. toc.ncx
    toc_header = <<-EOS
<?xml version="1.0" encoding="utf-8"?>
    <ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">
    <head>
    <meta name="dtb:uid" content="#{uid}"/>
    <meta name="dtb:depth" content="1"/>
    <meta name="dtb:totalPageCount" content="0"/>
    <meta name="dtb:maxPageNumber" content="0"/>
    </head>
    <docTitle>
    <text>#{metadata['title']}</text>
    </docTitle>
    EOS

    toc_entries = "<navMap>\n"
    toc_i = 0
    fileNames.each do |x|
        data = IO.read(book + '/'+x[:name])
        data.each_line do |l|
            new = l.clone
            title = l.clone
            title.strip!
            
            if(title.start_with? "<h1 class=\"caption\">")
                title["<h1 class=\"caption\">"] = "";
                title["</h1>"] = "";
                new["<h1 class=\"caption\">"] = "<h1 class=\"caption\" id=\"toc-item#{toc_i}\">";
                data[l] = new
                
                toc_entries += "<navPoint id=\"toc-item#{toc_i}\" class=\"data\" 
playOrder=\"#{toc_i}\">\n<navLabel>\n<text>#{title}</text>\n</navLabel>\n<content 
src=\"content/#{x[:name]}#toc-item#{toc_i}\" />\n</navPoint>\n"
                toc_i += 1;
            end
        end
        metadata['text'] = data
        out = parseTemplate(tmpl, metadata)
        f = File.open(epub_dir + "/content/#{x[:name]}", "w")
        f << out
        f.close()
    end
    toc_entries += "</navMap>\n"

    toc = File.open(epub_dir + "/toc.ncx", "w")
    toc << toc_header
    toc << toc_entries + "</ncx>"
    toc.close()

    puts "Successfully wrote epub file structure to #{epub_dir}."
    
    Zip::OutputStream.open(epub_filename) { |os|
            os.put_next_entry("mimetype", nil, nil, Zip::Entry::STORED)
            os << "application/epub+zip"
    }

    #afterwards, we can begin adding the "normal" files
    zipfile = Zip::File.open(epub_filename)
    Dir.each_recursive(epub_dir) do |path, filename|
            real_path = path + filename
            archive_path = path.sub(epub_dir + "/", "") + filename
            if !File.directory?(real_path) && !(filename == "mimetype")
                    zipfile.add(archive_path, real_path)
            end
    end
    zipfile.commit
    FileUtils.rm_rf(epub_dir)
end

