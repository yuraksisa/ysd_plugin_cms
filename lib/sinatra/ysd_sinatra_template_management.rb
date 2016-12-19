module Sinatra
  module YSD
  	#
  	# Sinatra extension to manage templates
  	#
  	module TemplateManagement
      def self.registered(app)
        
        #
        # Templates manager
        #
        app.get '/admin/cms/templates/?*', :allowed_usergroups => ['staff'] do

          aspects = []
          aspects << UI::GuiBlockEntityAspectAdapter.new(GuiBlock::TemplateTranslate.new, {:show_on_new => false} )
          aspects_render = UI::EntityManagementAspectRender.new({app:self}, aspects) 
            
          locals = aspects_render.render(ContentManagerSystem::Template)
          locals.store(:template_page_size, 20)
 
          load_em_page :template_management, :template, false, :locals => locals

        end


        #
        # Template traslation page
        #
        app.get "/admin/cms/translate/template/:template_id", :allowed_usergroups => ['staff'] do
      
          language_code = if language = ::Model::Translation::TranslationLanguage.find_translatable_languages.first
                            language.code
                          end      
      
          load_page :translate_template, :locals => {:template_id => params[:template_id], :language => language_code}
      
        end        

      end
  	end
  end
end