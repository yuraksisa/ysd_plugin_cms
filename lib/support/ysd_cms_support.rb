module ContentManagerSystem

  module Support
  
    #
    # It Renders a tab
    #
    def render_tab(id, description)
      tab = <<-TAB
        <li><a href="##{id}">#{description}</a></li>
      TAB
    end

  end #Support
end #ContentManagerSystem