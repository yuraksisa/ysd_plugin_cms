module UI
  #
  # It represents a pager
  #
  class Pager

    attr_reader :id, :description
    private_class_method :new

    def initialize(id, description)
      @id = id
      @description = description
      self.class.pagers << self
    end
    
    #
    # Get a pager
    #
    def self.get(id)
      (all.select {|element| element.id == id}).first
    end

    #
    # Get all pagers
    #
    def self.all
      pagers
    end
    
    #
    # Get all pages
    #
    def self.pagers
      @pagers ||= []
    end

    #
    # Retrieve the json version of the object
    #
    def to_json(*a)
    
      { :id => id,
        :description => description,
      }.to_json
     
    end

    SIMPLE_PAGER = new(:simple, 'Next and Previous page')
    PAGE_LIST_PAGER = new(:page_list, 'Page list')

  end
end