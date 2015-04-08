require 'fileutils'
require_relative 'targets/cover.rb'

def generateWebsite()
  downloadTargets = ["web", "epub"]
  ok_msg "GENERATING WEBSITE"
  FileUtils.mkpath "#{$outputPath}/website/"
  FileUtils.mkpath "#{$outputPath}/website/cover/"
  FileUtils.mkpath "#{$outputPath}/website/download/"
  
  
  config = YAML.load_file("#{$home}/config/site.yml")
  compass_compile("#{$home}/style/cover-small.scss")
  items = ""
  config["items"].each do |book|
    bookConfig, targets = getMetaData(book["path"])
    
    buy_html = ""
    if(book.has_key? "buy")
        book["buy"].each do |name,buy|
            buy["title"] = "Auf "+buy["site"]+" kaufen"
            buy_html = buy_html + 
                parseTemplate(IO.read("#{$home}/template/website.buyitem.html"), buy)
        end
    else
        buy_html = "Derzeit noch nicht verfügbar."
    end
    
    download_html = ""
    targets.each do |targetName, target|
        next if not downloadTargets.include? targetName
        conf = {}
        if(target == "web")
            old_file = genFileName(bookConfig, target)+"."+target['fileType']+".comp.pdf"
        else
            old_file = genFileName(bookConfig, target)+"."+target['fileType']
        end
        
        next if not File.exists? old_file
        
        new_link = "download/#{bookConfig['latinTitle']}-#{target['name']}.#{target['fileType']}"
        
        conf["title"] = target['webCaption']
        conf["link"] = new_link
        icon = ""
        if(target['fileType'] == "pdf")
            icon = "fa fa-file-pdf-o"
        elsif (target['fileType'] == "epub")
            icon = "fa fa-file-text"
        end
        conf["icon"] = icon
        FileUtils.copy old_file, "#{$home}/results/website/#{new_link}" 
        
        download_html = download_html + 
          parseTemplate(IO.read("#{$home}/template/website.downloadItem.html"), conf)
    end
    
    item_data = bookConfig
    
    item_data["download"] = download_html
    item_data["buy_items"] = buy_html
    img = "#{$outputPath}/website/cover/"+bookConfig['latinTitle'] + ".jpg"
    generateCoverSmall(bookConfig, "#{$outputPath}/website/cover/"+bookConfig['latinTitle'] + ".jpg") if($options[:genSmallCover])
    item_data["img"] ="cover/"+bookConfig['latinTitle'] + ".jpg"
    item_data["lang"] = bookConfig['languageCode']

    item = parseTemplate(IO.read("#{$home}/template/website.item.html"), item_data)
    
    items += item
  end
  website_data = {}
  website_data["items"] = items
  html = parseTemplate(IO.read("#{$home}/template/website.html"), website_data)
  
 
  File.open("#{$outputPath}/website/index.html", 'w') { |file| file.write(html) }
  FileUtils.copy_entry  "#{$home}/images/website/", "#{$outputPath}/website/images", false, false, true
  compass_compile("#{$home}/style/website.scss")
  FileUtils.copy  "#{$home}/style/website.css", "#{$outputPath}/website/website.css"
end
