require 'ysd-plugins' unless defined?Plugins::Plugin
require 'ysd_plugin_cms_extension'

Plugins::SinatraAppPlugin.register :cms do

   name=        'cms'
   author=      'yurak sisa'
   description= 'CMS integration'
   version=     '0.1'
   hooker       Huasi::CMSExtension
   sinatra_helper    Sinatra::ContentManagerHelpers
   sinatra_helper    Sinatra::YSD::ContentBuilderHelper           # Content Builder helper
   sinatra_extension Sinatra::YSD::ContentManagement              # Content management (/content/new)
   sinatra_extension Sinatra::YSD::CMS                            # Main sinatra application
   sinatra_extension Sinatra::YSD::Site                           # Site extension (homepage and direct resources)
   sinatra_extension Sinatra::YSD::Pages                          # Pages serving (/page/*)
   sinatra_extension Sinatra::YSD::ContentTypeManagement          # Content type management
   sinatra_extension Sinatra::YSD::TaxonomyManagement
   sinatra_extension Sinatra::YSD::TermManagement
   sinatra_extension Sinatra::YSD::ViewManagement
   sinatra_extension Sinatra::YSD::BlockManagement
   sinatra_extension Sinatra::YSD::MenuManagement
   sinatra_extension Sinatra::YSD::MenuItemManagement   
   sinatra_extension Sinatra::YSD::ContentManagementRESTApi
   sinatra_extension Sinatra::YSD::ContentSearchRESTApi
   sinatra_extension Sinatra::YSD::ContentTypeManagementRESTApi
   sinatra_extension Sinatra::YSD::TaxonomyManagementRESTApi
   sinatra_extension Sinatra::YSD::TermManagementRESTApi
   sinatra_extension Sinatra::YSD::ViewManagementRESTApi
   sinatra_extension Sinatra::YSD::BlockManagementRESTApi   
   sinatra_extension Sinatra::YSD::CommentRESTApi 
   sinatra_extension Sinatra::YSD::MenuManagementRESTApi
   sinatra_extension Sinatra::YSD::MenuItemManagementRESTApi   
   sinatra_extension Sinatra::YSD::PublishingRESTApi
   sinatra_extension Sinatra::YSD::CMSTranslation
   sinatra_extension Sinatra::YSD::CMSTranslationRESTApi
end