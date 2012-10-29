require 'erb' unless defined?ERB
#
# Use this class to render a tree structure
#
#  Examples of using this renderer:
#
#  start_tree        = "<ul class=\"menu\">"
#  start_branch_node = "<ul class=\"submenu submenu-level#{options[:level]}\"><li class=\"menuitem\"><a href=\"#{child[:link_route]}\">#{child[:title]}"
#  leaf_node         = "<li class=\"menuitem\"><a href=\"#{child[:link_route]}\">#{child[:title]}</a></li>"
#  end_branch_node   = "</a></li></ul>"
#  end_tree          = "</ul>"
#
#  menu = [{:id=>1,:title=>'about us',:children=>[]},{:id=>2,:title=>'contact',:children =>[]},{:id=>3,:title=>'conditions',:children=>[]}]
#
#  render = TreeRender.new(start_tree, start_branch_node, leaf_node, end_branch_node, end_tree)
#  render.render(menu)
#
#
class TreeRender
  
  def initialize(start_tree,
                 start_branch_node,
                 leaf_node,
                 end_branch_node,
                 end_tree,
                 separator)
                 
    @start_tree        = ERB.new(start_tree) 
    @start_branch_node = ERB.new(start_branch_node)
    @leaf_node         = ERB.new(leaf_node)
    @end_branch_node   = ERB.new(end_branch_node)
    @end_tree          = ERB.new(end_tree)
    @separator         = separator
                 
  end

  # It renders a tree structure
  #
  # @param [Hash] root_options
  #
  #   :id        The menu id
  #   :title     The menu title
  #   :children  The menu children
  #
  def render(root_options)
    
    root = root_options
    output = @start_tree.result(binding) 
    
    root_options[:children].each do |child|
    
      output << render_branch({:id => child[:id] , :title => child[:title], :level => 1, :link_route => child[:link_route], :children => child[:children]})
      
      if child != root_options[:children].last
        output << @separator
      end
      
    end
    
    output << @end_tree.result(binding)   
    
    output
      
  end
 
  private
  
  # It renders a tree branch
  #
  # @param [Hash] options
  #   :id
  #   :title
  #   :level
  #   :link_route
  #   :children The branch children
  #
  #
  def render_branch(options)
    
    output = ''
    
    branch = options
    
    if (options[:children].length > 0)
      output << @start_branch_node.result(binding)
    else
      leaf = options
      output << @leaf_node.result(binding)
    end
        
    options[:children].each do |child| 
      if child[:children].length > 0
        output << render_branch({:id => child[:id], :title => child[:title], :level => options[:level]+1, :link_route => child[:link_route], :children => child[:children]})
      else
        leaf = child
        output << @leaf_node.result(binding)  
      end
    end
    
    if (options[:children].length > 0)
      output << @end_branch_node.result(binding)
    end  
    
    output
  
  end
 
end