module Sinatra
  module YSD
    #
    # Traslation application
    #
    module CMSTranslation
    
      def self.registered(app)
      
        # Add the local folders to the views and translations     
        app.settings.views = Array(app.settings.views).push(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'views')))
        app.settings.translations = Array(app.settings.translations).push(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'i18n')))
            
        #
        # Content traslation page
        #
        app.get "/admin/cms/translate/content/:content_id" do

          language_code = if language = ::Model::Translation::TranslationLanguage.find_translatable_languages.first
                            language.code
                          end
                          
          #load_page 'translate_content', :locals => {:content_id => params[:content_id], :language => language_code}
          locals = {:content_id => params[:content_id], :language => [:language_code]}
          load_em_page(:translate_content, nil, false, :locals => locals)

        end
                
        #
        # Term traslation page
        #
        app.get "/admin/cms/translate/term/:term_id" do
      
          language_code = if language = ::Model::Translation::TranslationLanguage.find_translatable_languages.first
                            language.code
                          end      
      
          load_page 'translate_term', :locals => {:term_id => params[:term_id], :language => language_code}
      
        end
      
        #
        # Menu item traslation page
        #
        app.get "/admin/cms/translate/menuitem/:menu_item_id" do
                
          language_code = if language = ::Model::Translation::TranslationLanguage.find_translatable_languages.first
                            language.code
                          end
                          
          load_page 'translate_menu_item', :locals => {:menu_item_id => params[:menu_item_id], :language => language_code}
        
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