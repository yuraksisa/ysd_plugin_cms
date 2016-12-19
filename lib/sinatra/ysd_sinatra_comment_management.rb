module Sinatra
  module YSD
  	#
  	# Comments management Front-End
  	#
  	module CommentManagement

      def self.registered(app)
  		#
        # Comments management page
        #
        app.get "/admin/cms/comments", :allowed_usergroups => ['staff', 'editor', 'webmaster'] do
          
          context = {:app => self}          
          aspects = []
          aspects << UI::GuiBlockEntityAspectAdapter.new(GuiBlock::PublishingActions.new(nil), {:weight => -5, :in_group => false, :show_on_new => false}) 
          aspects_render = UI::EntityManagementAspectRender.new(context, aspects) 
          locals = aspects_render.render(ContentManagerSystem::Comment)

          locals.store(:comments_page_size,
            SystemConfiguration::Variable.get_value('cms.comments.page_size').to_i)
          locals.store(:publishing_states, build_publishing_state_translations.to_json )

          load_em_page('comments_management'.to_sym, :comment, 
          	           false, :locals => locals)

        end

        #
        # Get the Gui with the publishing actions 
        #
        app.get "/render/publishing-actions/comment/:id", :allowed_usergroups => ['staff', 'editor','webmaster'] do
 
           if comment = ContentManagerSystem::Comment.get(params[:id])
             aspects = []
             aspects << UI::GuiBlockEntityAspectAdapter.new(GuiBlock::PublishingActions.new(comment))
             aspects_render=UI::EntityManagementAspectRender.new({:app => self}, aspects) 
             aspects_render.render(ContentManagerSystem::Comment)[:edit_element_form]
           else
             status 401
           end
 
        end
      end

    end # CommentManagement
  end #YSD
end #Sinatra