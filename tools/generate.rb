#encoding: utf-8
$targets = [];
require 'fileutils'
require 'optparse'
require 'yaml'
#require 'i18n'
require_relative 'libs.rb'
require_relative 'targets/book.rb'
require_relative 'targets/pandocBook.rb'
require_relative 'targets/cover.rb'
require_relative 'targets/epub.rb'
require_relative 'generateWebsite.rb'

$home = "/home/paul/Cloud/Bibliothek/PreciousBooksTreasury"
$outputPath = $home+"/results"
$ru = Hash["l-toc" =>"Оглавление"]
$de = Hash["l-toc" => "Inhaltsverzeichnis"]
$en = Hash["l-toc" => "Index"]

def getOptions()
    options = {}
    options[:cleanUp] = true
    optparse = OptionParser.new do|opts|
        opts.banner = "Usage: generate.rb [options]"
    
        opts.on('--includePath PATH', 'Only this Path' ) do |x|
            options[:includePath] = x
            puts x
        end
        opts.on('--includeTarget TARGET', 'Only this Target' ) do |x|
            options[:includeTarget] = x
            puts x
        end
        opts.on('--excludeTarget TARGET', 'All but not this target' ) do |x|
            options[:excludeTarget] = x
            puts x
        end
         opts.on('--noCleanUp', 'Do not cleanup' ) do 
            options[:cleanUp] = false
            puts x
        end
    end.parse!
    return options
end

def main()
    prepareUniverse()
    compassCompile();
    #generate all
    $options = getOptions()
    Dir.glob($home + "/**/*").each do |item| # scan all folders
        next if item == '.' or item == '..' # skip
        next if(not File.directory? item) # skip files
        next if(not File.exists?(item + "/metadata.yml"))
        next if $options[:includePath] != nil and (not item.include? $options[:includePath])
        puts item
        metadata, targets = getMetaData(item)
        next if targets == []
        
        targets.each do |name, t|
            puts "\n\n \e[32mGENERATING\e[0m \e[1m#{name}\e[0m of #{item} \n\n"
            metadata_copy = metadata.merge(t)
            metadata_copy = prepareMetadata(metadata_copy)
            
            if(t['type'] == "print")
                puts "\n\n    \e[33mGENERATING\e[0m  PDF of #{item} \n\n"
                generatePandocPDF(item, metadata_copy, t) if targetIncluded? "book"
                puts "\n\n    \e[33mGENERATING\e[0m  cover config of #{item} \n\n"
                generateCoverFile(item, metadata_copy, t) if targetIncluded? "cover"
                puts "\n\n    \e[33mGENERATING\e[0m  cover of #{item} \n\n"
                generateCover(item, metadata_copy, t, $home + "/template/cover.html") if targetIncluded? "cover"
            elsif(t['type'] == "epub")
                generatePandocEPUB(item, metadata_copy, t) if targetIncluded? "book"
            end
        end
    end
    generateWebsite();
end
def targetIncluded?(name)
    if $options[:includeTarget] != nil
        return $options[:includeTarget] == name
    end
    
    if $options[:excludeTarget] != nil
         return $options[:excludeTarget] != name
    end
    return true
end
main()
