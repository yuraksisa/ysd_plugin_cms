require 'ysd_md_menu'

module Sinatra
  module YSD
    #
    # Menu item management
    # 
    module MenuItemManagement
       
      def self.registered(app)
                       
        #
        # Menu item management page
        #        
        app.get "/admin/cms/menu-item-management/:menu_name/?*", :allowed_usergroups => ['staff','webmaster']  do

          if menu = ::Site::Menu.get(params[:menu_name])
            
            aspects = [UI::GuiBlockEntityAspectAdapter.new(
              GuiBlock::MenuItemTranslate.new, {:show_on_new => false})]

            aspects_render = UI::EntityManagementAspectRender.new({app:self}, 
              aspects) 
            
            locals = aspects_render.render(::Site::MenuItem) #content_type)            
            locals.store(:title, t.menu_item_management.title(menu.name))
            load_em_page(:menu_item_management, :menuitem, true, :locals => locals)
          else
            status 404
          end

        end
              
      end
    
    end #MenuItemManagement
  end #YSD
end #Sinatra