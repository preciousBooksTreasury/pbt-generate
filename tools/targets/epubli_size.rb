require "uri"
require "net/http"
require 'json'
$epublisize = {}
$epublisize["taschenbuch"] = 9
$epublisize["a5"] = 3
$epublisize["a4"] = 1

$epublibinding = {}
$epublibinding["Softcover"] = 5
$epublibinding["Hardcover"] = 3
$epublibinding["Booklet"] = 8
def parse_epubli(a)
    b = a.split(" ")
    return "mm-to-px(#{b[0]})"
end
# return : :width, :height :back, :beginn
def getEpubliSize(size, bind, pagecount)
    params = {  
        'e_calculator_size' => $epublisize[size],
        'e_calculator_binding' => $epublibinding[bind],
        'e_calculator_paper' => 1,
        'e_calculator_numPages' => pagecount
        }
    puts params
    x = Net::HTTP.post_form(URI.parse('http://www.epubli.de/interfaces/coverCalc.php'), params)
    puts x.body
    ret = JSON.parse(x.body)
    width = parse_epubli(ret['results']['coverWidth'])
    height = parse_epubli(ret['results']['coverHeight'])
    back = parse_epubli(ret['results']['spineWidth'])
    beginn = parse_epubli(ret['results']['pageWidth'])
    bleed = parse_epubli(ret['results']['bleed'])
    return width,height,back,beginn, bleed
end
    