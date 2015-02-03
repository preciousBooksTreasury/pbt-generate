
=begin
def loadSettings()
    $books_c = YAML::load_file "books-cache.yml"
    $covers_c = YAML::load_file "covers-cache.yml"
end

def saveSettings()
    File.open("books-cache.yml", "w") do |file|
        file.write $books_c.to_yaml
    end
    File.open("covers-cache.yml", "w") do |file|
        file.write $covers_c.to_yaml
    end
end
=end