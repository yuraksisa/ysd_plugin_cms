module Sinatra
  module YSD
  	#
  	# Sinatra extension to manage templates
  	#
  	module TemplateManagement
      def self.registered(app)

        #
        # Edit a template
        #
        app.get '/admin/cms/templates/:id/edit', :allowed_usergroups => ['staff'] do

          @template = ContentManagerSystem::Template.get(params[:id])
          @show_translations = settings.multilanguage_site
          load_page(:template_edit)

        end


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


      end
  	end
  end
end