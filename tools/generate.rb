#encoding: utf-8
$targets = [];
require 'fileutils'
require 'optparse'
require 'yaml'
#require 'i18n'
require_relative 'libs.rb'
require_relative 'targets/pandocBook.rb'
require_relative 'targets/cover.rb'
require_relative 'targets/epub.rb'
require_relative 'generateWebsite.rb'

$home = "/home/paul/Cloud/Bibliothek/PreciousBooksTreasury"
$cover = "/run/media/paul/Transcend/PreciousBooksTreasury/cover"
$outputPath = $home+"/results"
$ru = Hash["l-toc" =>"Оглавление"]
$de = Hash["l-toc" => "Inhaltsverzeichnis"]
$en = Hash["l-toc" => "Index"]

def getOptions()
    options = {}
    options[:cleanUp] = true
    options[:onlyCover] = false
    options[:genSmallCover] = false
    optparse = OptionParser.new do|opts|
        opts.banner = "Usage: generate.rb [options]"
    
        opts.on('--includePath PATH', 'Only this Path' ) do |x|
            options[:includePath] = x
        end
        opts.on('--includeTarget TARGET', 'Only this Target' ) do |x|
            options[:includeTarget] = x
        end
         opts.on('--includeType TYPE', 'Only this Type' ) do |x|
            options[:includeType] = x
        end
        opts.on('--excludeTarget TARGET', 'All but not this target' ) do |x|
            options[:excludeTarget] = x
        end
        opts.on('--noCleanUp', 'Do not cleanup' ) do 
            options[:cleanUp] = false
        end
        opts.on('--onlyCover', 'Only Cover' ) do 
            options[:onlyCover] = true
        end
        opts.on('--genSmallCover', 'Generate Small Covers' ) do 
            options[:genSmallCover] = true
        end
    end.parse!
    return options
end

def main()
    prepareUniverse()
    compassCompile();
    #generate all
    $options = getOptions()
    Dir.glob($home + "/books/**/*").each do |item| # scan all folders
        next if item == '.' or item == '..' # skip
        next if not item.end_with? '.markdown'
        next if $options[:includePath] != nil and (not item.include? $options[:includePath])
        puts item
        metadata, targets = getMetaData(item)
        next if targets == [] or metadata == nil
        
        targets.each do |name, t|
            next if($options[:includeType] != nil and t['type'] != $options[:includeType])
            puts "\n\n \e[32mGENERATING\e[0m \e[1m#{name}\e[0m of #{item} \n\n"
            metadata_copy = metadata.merge(t)
            metadata_copy = prepareMetadata(metadata_copy)
            puts t
           
                    
            if(t['type'] == "print")
                if(not $options[:onlyCover])
                    puts "\n\n    \e[33mGENERATING\e[0m  PDF of #{item} \n\n"
                    generatePandocPDF(item, metadata_copy, t) if target_included? "book"
                end
                
                puts "\n\n    \e[33mGENERATING\e[0m  cover config of #{item} \n\n"
                generateCoverFile(item, metadata_copy, t) if target_included? "cover"
                puts "\n\n    \e[33mGENERATING\e[0m  cover of #{item} \n\n"
                generateCover(item, metadata_copy, t, $home + "/template/cover.html") if target_included? "cover"
            elsif(t['type'] == "epub")
                generatePandocEPUB(item, metadata_copy, t) if target_included? "book"
            elsif(t['type'] == "web")
                next if not target_included? "book"
                file_name = generatePandocPDF(item, metadata_copy, t)
                compress_pdf(file_name)
            end
        end
    end
    generateWebsite();
end
def target_included?(name)
    if $options[:includeTarget] != nil
        return $options[:includeTarget] == name
    end
    
    if $options[:excludeTarget] != nil
         return $options[:excludeTarget] != name
    end
    return true
end
main()
