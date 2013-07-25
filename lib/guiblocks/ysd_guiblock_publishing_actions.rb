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
      renderer.render('form', 'em', {:publishing_buttons => publishing_buttons(context, aspect_model)}) 

    end

    #
    # Editing support
    #
    def element_form_extension(context={}, aspect_model)
    
      app = context[:app]
      
      renderer = ::UI::FieldSetRender.new('publishing', app)      
      renderer.render('formextension', 'em', {:model => aspect_model.aspect_target_model.name.split('::').last.downcase })      

    end   


    private

    def publishing_buttons(context={}, aspect_model)

     if publishable.nil?
       return ''
     end

     app = context[:app]

      actions = []
      action_url = nil
      action_class = nil
      
      model = aspect_model.aspect_target_model.name.split('::').last.downcase

      publishable.publishing_actions.each do |pub_action| 
         
         case pub_action
                when ContentManagerSystem::PublishingAction::CONFIRM
                  action_url   = "/api/#{model}/confirm/#{publishable.publication_info[:id]}"
                  action_class = "black-button"
                when ContentManagerSystem::PublishingAction::VALIDATE
                  action_url = "/api/#{model}/validate/#{publishable.publication_info[:id]}"
                  action_class = "green-button"
                when ContentManagerSystem::PublishingAction::PUBLISH
                  action_url = "/api/#{model}/publish/#{publishable.publication_info[:id]}"
                  action_class = "blue-button"
                when ContentManagerSystem::PublishingAction::BAN
                  action_url = "/api/#{model}/ban/#{publishable.publication_info[:id]}"
                  action_class = "red-button"
                when ContentManagerSystem::PublishingAction::ALLOW
                  action_url = "/api/#{model}/allow/#{publishable.publication_info[:id]}"
                  action_class = "blue-button"
          end

          actions << {:id => pub_action.id, 
                      :title => app.t.publishing.action[pub_action.id.downcase.to_sym], 
                      :text => app.t.publishing.action[pub_action.id.downcase.to_sym], 
                      :action_method => :POST, 
                      :action_url => action_url, 
                      :confirm_message => app.t.guiblock.publishing[pub_action.id.downcase.to_sym].message,
                      :class=>"publishing-button #{action_class}"}
      end

      buttons = ''
      actions.each do |action|
        buttons << app.render_element_action_button(action)
      end

      return buttons

    end

  end #Publishing Actions

end #Publishing Actions