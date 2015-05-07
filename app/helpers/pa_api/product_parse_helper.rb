module PaApi::ProductParseHelper
  
    def self.parse_to_offers(res, market_place_id)
      offers = []
      root_nodes = []
      items = res.items
      items ||= []        
      items.each do |item|
        Rails.logger.debug item.to_s
        
        search_time = Time.now
    
        Rails.logger.debug item.get('ASIN')
        entity = self.new(
          :asin => item.get('ASIN'),
          :market_place_id => market_place_id,
          :target_date => search_time.strftime("%Y%m%d"),
          :search_time => search_time,
        )
        
        offer_elems = item.get_elements('Offers/Offer')
        offer_elems ||= []
        
        offer_elems.each do |offer_elem|
          seller_name =  offer_elem.get_element('./Merchant').get('Name')
          if leader_name? seller_name
            entity.leader_price = offer_elem.get_element('./OfferListing/Price').get('Amount').to_f
            Rails.logger.debug "Leader Price: #{entity.leader_price}@#{seller_name}"
            break
          end
        end
          
        Rails.logger.info entity.inspect
        offers << entity
      end
      offers
    end
    
    def self.parse_to_entity(res, market_place_id)
      # root_node_ids = Amazon::Node.uniq_root_node_ids
      # Rails.logger.debug "Root node ids = #{root_node_ids}"
      
      entities = []
      root_nodes = []
      res.items.each do |item|
        Rails.logger.debug item.to_s
        
        entity = self.new(
          :asin => item.get('ASIN'),
          :market_place_id => market_place_id
        )
        Rails.logger.debug item.get('ASIN')
        attr_elem = item.get_element('./ItemAttributes')
        if attr_elem.present?
          # entity.title = attr_elem.get_element('./Title').get
          entity.item_name = get_string_value(attr_elem, './Title')[0, 254]
          # unescape html < > & " '
          entity.item_name = CGI.unescapeHTML entity.item_name if entity.item_name.present?
          
          entity.ean = get_string_value(attr_elem, './EAN') 
          entity.product_code = get_string_value(attr_elem, './Model', './SeikodoProductCode') 
    
          if exists_elem?(attr_elem, './PackageDimensions')
            dimention_elem = attr_elem.get_element('./PackageDimensions')
            entity.height = get_float_value(dimention_elem, './Height')
            entity.length = get_float_value(dimention_elem, './Length')
            entity.width = get_float_value(dimention_elem, './Width')
            entity.size_units = get_string_value(dimention_elem, './Height/@Units')
    
            if exists_elem?(dimention_elem, './Weight')
              entity.weight = get_float_value(dimention_elem, './Weight')
              entity.weight_units = get_string_value(dimention_elem, './Weight/@Units')
            end
          end
        end
        
        entity.on_sale_date = get_time_value(attr_elem, './ReleaseDate', './PublicationDate')
    
        entity.search_index = get_string_value(attr_elem, './ProductGroup')
    
        entity.package_quantity = get_int_value(attr_elem, './NumberOfDiscs', './PackageQuantity')
        
        entity.fixed_price = get_int_value(attr_elem, './ListPrice/Amount')
        
        entity.s_image_path = get_string_value(item, 'SmallImage/URL')
        entity.m_image_path = get_string_value(item, 'MediumImage/URL')
        entity.l_image_path = get_string_value(item, 'LargeImage/URL')
    
        # node_elems = item.get_elements('./BrowseNodes/BrowseNode')
        # root_node_id = nil
    #           
        # if node_elems.blank?
          # node_elems ||= []
          # search_nodes = Amazon::Node.where(:search_index => entity.search_index)
          # root_node_id = search_nodes.first.root_node_id if search_nodes.present?
        # end
    #           
        # node_elems.each do |node_elem|
          # has_ancester = true
          # ancestor_node = node_elem
          # while has_ancester do
            # ancestor_node = ancestor_node.get_element('./Ancestors/BrowseNode')
            # if ancestor_node.present? && ancestor_node.get_element('./IsCategoryRoot').present?
              # has_ancester = false
              # node_id = get_string_value(ancestor_node, './BrowseNodeId')
              # ancester_node_id = get_string_value(ancestor_node, './Ancestors/BrowseNode/BrowseNodeId')
              # ancester_node_name = get_string_value(ancestor_node, './Ancestors/BrowseNode/Name')
    #     
              # next if ancester_node_name.blank?
    #     
              # root_nodes << Amazon::Node.new(
                # :node_id => ancester_node_id,
                # :node_name => get_string_value(ancestor_node, './Ancestors/BrowseNode/Name'),
                # :root_node_id => ancester_node_id,
                # :search_index => entity.search_index,
                # :result_count => 0,
                # :active => 1,
                # :level => 1
              # )
              # Amazon::Node.import root_nodes
    #     
              # if root_node_ids.include?(ancester_node_id)
                # root_node_id = ancester_node_id
                # Rails.logger.debug "At ancester layer. Root node id is #{root_node_id}."
              # elsif root_node_ids.include?(node_id)
                # root_node_id = node_id
                # Rails.logger.debug "At same layer, Root node id is #{root_node_id}."
              # else
                # Rails.logger.debug "They are not root node id. #{node_id} / #{ancester_node_id}."
              # end
            # end
            # has_ancester = false unless exists_elem?(ancestor_node, './Ancestors')
          # end
        # end
        # entity.root_node_id = root_node_id
        entity.define_size
        entity.initialized = true
        entity.initialized_at = Time.now
        
        Rails.logger.info entity.inspect
        entities << entity
      end
      entities
    end
    
    def self.get_string_value(elem, *path)
      get_value(elem, path)
    end
    
    def self.get_value(elem, path)
      target_elem = nil
      return nil if elem.blank?
      
      path.each do |a_path|
        target_elem ||= elem.get_element a_path
      end
      
      value = target_elem.get if target_elem.present?
      value
    end
    
    def self.get_int_value(elem, *path)
      ret = nil
      val = get_value(elem, path)
      ret = val.to_i if val.present?
      ret
    end
    
    def self.get_float_value(elem, *path)
      ret = nil
      val = get_value(elem, path)
      ret = val.to_f if val.present?
      ret
    end
    
    def self.get_time_value(elem, *path)
      val = get_value(elem, path)
      return nil if val.blank?
      
      Rails.logger.debug val
      if val.split("-").length < 2
        val = "#{val}-01-01" 
      elsif val.split("-").length < 3
        val = "#{val}-01"
      end
      Rails.logger.debug "-> #{val}"
      Time.parse val
    end
    
    def self.exists_elem?(elem, *path)
      target_elem = nil
      path.each do |a_path|
        target_elem ||= elem.get_element a_path
      end
      target_elem.present?
    end
    
    def inch_to_mm(inches)
      inches.to_f * 25.4
    end
    
    def mm_to_inch(mm)
      mm.to_f / 25.4
    end
    
    def pound_to_gram(pounds)
      pounds.to_f * 453.59237
    end
    
    def gram_to_pound(gram)
      gram.to_f / 453.59237
    end
    
    def define_size
      ret = [self.define_size_by_weight, self.define_size_by_cube].sort_by{|item| -item}
      
      size_value = nil
      case ret.first
      when 3 then
        size_value = 'Large'
      when 2 then
        size_value = 'Medium'
      when 1 then
        size_value = 'Small'
      end
      self.size = size_value
    end
    
    def define_size_by_weight
      return 0 if self.weight.blank?
      
      if self.weight > gram_to_pound(9000)*100.0
        return 3
      elsif self.weight <= gram_to_pound(9000)*100.0 &&  self.weight > gram_to_pound(250)*100.0
        return 2
      else
        return 1
      end
    end
    
    def define_size_by_cube
      return 0 if self.height.blank? || self.width.blank? || self.length.blank?
      
      dimension = [self.height, self.width, self.length].sort_by{|item| -item}
      
      small_criteria = [mm_to_inch(250)*100.0, mm_to_inch(180)*100.0, mm_to_inch(20)*100.0]
      medium_criteria = [mm_to_inch(450)*100.0, mm_to_inch(350)*100.0, mm_to_inch(20)*100.0]
      
      if under_cube?(dimension, small_criteria) 
        return 1
      elsif under_cube?(dimension, medium_criteria) 
        return 2
      else
        return 3
      end
    end
    
    def cube_length
      (inch_to_mm(self.height) + inch_to_mm(self.width) + inch_to_mm(self.length))/100
    end
    
    def cube_range
      [inch_to_mm(self.height)/100, inch_to_mm(self.width)/100, inch_to_mm(self.length)/100].sort {|a, b| b <=> a }
    end
    
    def under_cube?(dimension, criteria)
      dimension[0] < criteria[0] && dimension[1] < criteria[1] && dimension[1] < criteria[1]
    end
end