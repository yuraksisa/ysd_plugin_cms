require 'ysd-plugins' unless defined?Plugins::Plugin
require 'ysd_plugin_cms_extension'

Plugins::SinatraAppPlugin.register :cms do

   name=        'cms'
   author=      'yurak sisa'
   description= 'CMS integration'
   version=     '0.1'
   hooker       Huasi::CMSExtension
   sinatra_helper    Sinatra::ContentManagerHelpers
   sinatra_extension Sinatra::YSD::CMS                            # Main sinatra application
   sinatra_extension Sinatra::YSD::ContentManagement              # Content management
   sinatra_extension Sinatra::YSD::ContentTypeManagement          # Content type management
   sinatra_extension Sinatra::YSD::TaxonomyManagement
   sinatra_extension Sinatra::YSD::TermManagement
   sinatra_extension Sinatra::YSD::ViewManagement
   sinatra_extension Sinatra::YSD::BlockManagement
   sinatra_extension Sinatra::YSD::ContentManagementRESTApi
   sinatra_extension Sinatra::YSD::ContentTypeManagementRESTApi
   sinatra_extension Sinatra::YSD::TaxonomyManagementRESTApi
   sinatra_extension Sinatra::YSD::TermManagementRESTApi
   sinatra_extension Sinatra::YSD::ViewManagementRESTApi
   sinatra_extension Sinatra::YSD::BlockManagementRESTApi   
end