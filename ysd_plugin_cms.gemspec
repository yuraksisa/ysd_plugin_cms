Gem::Specification.new do |s|
  s.name    = "ysd_plugin_cms"
  s.version = "0.1"
  s.authors = ["Yurak Sisa Dream"]
  s.date    = "2012-03-15"
  s.email   = ["yurak.sisa.dream@gmail.com"]
  s.files   = Dir['lib/**/*.rb','views/**/*.erb','i18n/**/*.yml','static/**/*.*'] 
  s.description = "CMS integration in huasi"
  s.summary = "CMS integration in huasi"
  
  s.add_runtime_dependency "json"
  
  s.add_runtime_dependency "ysd_md_cms"                   # The model
  s.add_runtime_dependency "ysd_core_plugins"             # The plugins system
  s.add_runtime_dependency "ysd_core_themes"              # The theme system 
  s.add_runtime_dependency "ysd_plugin_entitymanagement"  # Framework for creating managements
  s.add_runtime_dependency "ysd_ui_cms_renders"           # Rendering the components

  
end
