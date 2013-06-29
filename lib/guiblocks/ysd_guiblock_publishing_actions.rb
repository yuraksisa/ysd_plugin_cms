require 'ysd_md_publishing_action'

module GuiBlock
  
  #
  # Publishing actions
  #
  class PublishingActions

    attr_reader :publishable, :em_action

    def weight
      99
    end

    def in_group
      false
    end

    def show_on_new
      false
    end

    def show_on_edit
      true
    end

    def show_on_view
      false
    end

    def get_aspect_definition(context={})
      return self
    end

    #
    # Constructor
    #
    def initialize(publishable)
      @publishable = publishable
    end
    
    #
    # Information
    #
    def element_info(context={})
      app = context[:app]
      {:id => 'publishing', :description => "#{app.t.guiblock.publishing.description}"} 
    end

    #
    # Edit Form tab
    #
    def element_form_tab(context={}, aspect_model)
      app = context[:app]

      info = element_info(context)
      app.render_tab("#{info[:id]}_form", info[:description])

    end

    #
    # Form
    #
    def element_form(context={}, aspect_model)

      app = context[:app]

      renderer = ::UI::FieldSetRender.new('publishing', app)      
      renderer.render('form', 'em', {:publishing_buttons => publishing_buttons(context)}) 

    end

    #
    # Editing support
    #
    def element_form_extension(context={}, aspect_model)
    
      app = context[:app]

      renderer = ::UI::FieldSetRender.new('publishing', app)      
      renderer.render('formextension', 'em')      

    end   


    private

    def publishing_buttons(context={})

     app = context[:app]

      actions = []

      publishable.publishing_actions.each do |pub_action| 
        if url = case pub_action
                when ContentManagerSystem::PublishingAction::CONFIRM
                   "/content/confirm/#{publishable.publication_info[:id]}"
                when ContentManagerSystem::PublishingAction::VALIDATE
                   "/content/validate/#{publishable.publication_info[:id]}"
                when ContentManagerSystem::PublishingAction::PUBLISH
                   "/content/publish/#{publishable.publication_info[:id]}"
                when ContentManagerSystem::PublishingAction::BAN
                   "/content/ban/#{publishable.publication_info[:id]}"
                when ContentManagerSystem::PublishingAction::ALLOW
                  "/content/allow/#{publishable.publication_info[:id]}"
              end
          actions << {:id => pub_action.id, 
                      :title => app.t.publishing.action[pub_action.id.downcase.to_sym], 
                      :text => app.t.publishing.action[pub_action.id.downcase.to_sym], 
                      :action_method => :POST, 
                      :action_url => url, 
                      :confirm_message => app.t.guiblock.publishing[pub_action.id.downcase.to_sym].message,
                      :class=>"publishing-button publishing-button-#{pub_action.id.downcase}"}
        end
      end

      buttons = ''
      actions.each do |action|
        buttons << app.render_element_action_button(action)
      end

      return buttons

    end

  end #Publishing Actions

end #Publishing Actions