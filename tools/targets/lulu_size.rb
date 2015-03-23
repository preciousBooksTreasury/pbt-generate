require "uri"
require "net/http"
require 'json'



module LuluCover
  $lulusize = {}
  $lulusize["taschenbuch"] = 4
  $lulusize["digest"] = 18
  $lulusize["a5"] = 15
  $lulusize["a4"] = 11


  $lulubinding = {}
  $lulubinding["Softcover"] = 2
  $lulubinding["Booklet"] = 3
  $lulubinding["Hardcover"] = 4
  def LuluCover.cmToPx(a)
      return "mm-to-px(#{a*10})"
  end
  
  
  # return : :width, :height :back, :beginn
  def LuluCover.getSize(size, bind, pagecount)
    error_msg("Wrong size name #{size}") if not $lulusize.has_key? size
    error_msg("Wrong binding name #{bind}") if not $lulubinding.has_key? bind
    
    package = LuluCover.findPackage($lulusize[size],$lulubinding[bind], 2)
    return LuluCover.calculate(package, pagecount)
  end
      
  def LuluCover.calculate(package, pagecount)
    height = LuluCover.cmToPx(package["cover_measurements"]["full_height_with_bleed"]["cm"].to_f)
    back = package["per_page_thickness"]["cm"].to_f * pagecount.to_f
    beginn = package["cover_measurements"]["distance_to_spine_with_bleed"]["cm"].to_f
    
    width = LuluCover.cmToPx(beginn*2+back)
    bleed = LuluCover.cmToPx(0)
    
    return width,height,LuluCover.cmToPx(back),LuluCover.cmToPx(beginn),bleed
    
  end
  
  def LuluCover.findPackage(trimsize_id, binding_id, interior_id)
    lulu_json = JSON.parse(File.read("#{$home}/config/lulu_config.json"))
    packages = lulu_json["packages"]
    packages.each do |key,x|
      if(x["binding_id"].to_i == binding_id && x["trimsize_id"].to_i == trimsize_id) 
        return x 
      end
    end
    error_msg("Lulu Package trimsize_id = #{trimsize_id} bindinding_id = #{binding_id} not found")
    return nil
  end
  
  def LuluCover.findPackageById(package_id)
    lulu_json = JSON.parse(File.read("#{$home}/config/lulu_config.json"))
    packages = lulu_json["packages"]
    packages.each do |key,x|
      if(x["package_id"].to_i == package_id) 
        return x 
      end
    end
    return nil
  end
end