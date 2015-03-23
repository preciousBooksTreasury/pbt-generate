require 'fileutils'

def generateWebsite()
  ok_msg "GENERATING WEBSITE"
  config = YAML.load_file("#{$home}/config/site.yml")
  
  items = ""
  config["items"].each do |book|
    bookConfig = YAML.load_file("#{$home}/#{book["path"]}/metadata.yml")
    
    buy_html = ""
    book["buy"].each do |name,buy|
      buy["title"] = "Auf "+buy["site"]+" kaufen"
      buy_html = buy_html + 
          parseTemplate(IO.read("#{$home}/template/website.buyitem.html"), buy)
    end
    item_data = bookConfig
    item_data["download"] = ""
    item_data["buy_items"] =  buy_html

    item = parseTemplate(IO.read("#{$home}/template/website.item.html"), item_data)
    
    items += item
  end
  website_data = {}
  website_data["items"] = items
  html = parseTemplate(IO.read("#{$home}/template/website.html"), website_data)
  
  FileUtils.mkpath "#{$outputPath}/website/"
  File.open("#{$outputPath}/website/index.html", 'w') { |file| file.write(html) }
end


