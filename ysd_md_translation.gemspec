Gem::Specification.new do |s|
  s.name    = "ysd_md_translation"
  s.version = "0.1"
  s.authors = ["Yurak Sisa Dream"]
  s.date    = "2012-07-19"
  s.email   = ["yurak.sisa.dream@gmail.com"]
  s.files   = Dir['lib/**/*.rb']
  s.summary = "Yurak Sisa Translation model"
  
  s.add_runtime_dependency "data_mapper", "1.1.0"
  s.add_runtime_dependency "dm-types", "1.1.0"    # View JSON field
  
  s.add_runtime_dependency "ysd_md_cms"           # CMS (content, term)
  s.add_runtime_dependency "ysd_md_site"          # Site model (menu item) 
  
end
