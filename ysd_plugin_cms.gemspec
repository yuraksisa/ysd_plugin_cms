Gem::Specification.new do |s|
  s.name    = "ysd_plugin_cms"
  s.version = "0.2.41"
  s.authors = ["Yurak Sisa Dream"]
  s.date    = "2012-03-15"
  s.email   = ["yurak.sisa.dream@gmail.com"]
  s.files   = Dir['lib/**/*.rb','views/**/*.erb','i18n/**/*.yml','static/**/*.*'] 
  s.description = "CMS integration in huasi"
  s.summary = "CMS integration in huasi"
  
  s.add_runtime_dependency "json"
  
  s.add_runtime_dependency "ysd_md_cms",">=0.2.0"         # The model
  s.add_runtime_dependency "ysd_core_plugins"             # The plugins system
  s.add_runtime_dependency "ysd_core_themes"              # The theme system 
  s.add_runtime_dependency "ysd_yito_core"                # Base component to create Web
  s.add_runtime_dependency "ysd_yito_js"                  # Base component to create the Web front end
  s.add_runtime_dependency "ysd_plugin_aspects"           # Aspects management
  s.add_runtime_dependency "ysd_plugin_rca"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rack"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "sinatra"
  s.add_development_dependency "sinatra-r18n"
  s.add_development_dependency "dm-sqlite-adapter" # Model testing using sqlite  

end
