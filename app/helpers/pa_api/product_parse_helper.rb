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
      entities = []
      root_nodes = []
      res.items.each do |item|
        Rails.logger.debug item.to_s
        
        entity = self.new(
          :asin => item.get('ASIN'),
          :market_place_id => market_place_id
        )
        detail = self.get_detail_class.new(
            :item_id => item.get('ASIN'),
            :market_place_id => market_place_id
        )

        Rails.logger.debug item.get('ASIN')
        attr_elem = item.get_element('./ItemAttributes')

        features = []
        if attr_elem.present?
          # 商品名
          entity.item_name = get_string_value(attr_elem, './Title')[0, 254] # 254文字に短縮
          # unescape html < > & " '
          # HTMLエスケープを解除
          entity.item_name = CGI.unescapeHTML entity.item_name if entity.item_name.present?
          # EANコード
          entity.ean = get_string_value(attr_elem, './EAN')
          # 型番
          entity.product_code = get_string_value(attr_elem, './SeikodoProductCode', './Model', './MPN')

          # 発売日
          entity.on_sale_date = get_time_value(attr_elem, './ReleaseDate', './PublicationDate')
          # 製品グループ
          entity.search_index = get_string_value(attr_elem, './ProductGroup')
          # 内容物数
          entity.package_quantity = get_int_value(attr_elem, './NumberOfDiscs', './PackageQuantity')
          # メーカー希望小売価格
          entity.fixed_price = get_int_value(attr_elem, './ListPrice/Amount')

          # 商品包装サイズを収集
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

          # 製品仕様
          feature_elems = attr_elem.get_elements('./Feature')
          feature_elems ||= []
          feature_elems.each do |feature|
            features << get_string_value(feature, './')
          end
        end

        # メイン画像URL
        entity.s_image_path = get_string_value(item, 'SmallImage/URL') if exists_elem?(item, 'SmallImage')
        entity.m_image_path = get_string_value(item, 'MediumImage/URL') if exists_elem?(item, 'MediumImage')
        entity.l_image_path = get_string_value(item, 'LargeImage/URL') if exists_elem?(item, 'LargeImage')

        # サブ画像URL
        image_urls = []
        if exists_elem?(item, 'ImageSets')
          imageset_elems = item.get_elements('ImageSets/SimilarProduct')
          imageset_elems ||= []
          imageset_elems.each do |imageset_elem|
            if get_string_value(imageset_elem, './@Category') == "variant"
              image_urls << {
                  small: get_string_value(imageset_elem, './SmallImage/URL'),
                  medium: get_string_value(imageset_elem, './MediumImage/URL'),
                  large: get_string_value(imageset_elem, './LargeImage/URL'),
              }
            end
          end
        end

        # 類似商品
        similar_asins = []
        if exists_elem?(item, 'SimilarProducts')
          similar_elems = item.get_elements('SimilarProducts/SimilarProduct')
          similar_elems ||= []
          similar_elems.each do |similar_elem|
            similar_asins <<  similar_elem.get('./ASIN')
          end
        end
        item.similar_asins = similar_asins.join(',') if similar_asins.present?

        # カテゴリ
        browse_nodes = []
        if exists_elem?(item, 'BrowseNodes')
          node_elems = item.get_elements('BrowseNodes/BrowseNode')
          node_elems ||= []
          nodes = []
          node_elems.each do |node_elem|
            browse_nodes <<  get_browse_node(node_elem, nodes, "Ancestors")
          end
        end

        # 商品説明
        product_description = nil
        if exists_elem?(item, 'EditorialReviews')
          review_elem = item.get_element('EditorialReviews/EditorialReview')
          product_description = get_string_value(review_elem, './Content')
        end

        # 詳細情報の構築
        detail.features = features.to_json if features.present?
        detail.similarities = similar_asins.to_json if similar_asins.present?
        detail.image_urls = image_urls.to_json if image_urls.present?
        detail.product_description = product_description if product_description.present?
        detail.browse_nodes = browse_nodes.to_json if browse_nodes.present?
        entity.detail_data = detail
        p detail.inspect

        # サイズの決定
        entity.define_size
        entity.initialized = true
        entity.initialized_at = Time.now
        
        Rails.logger.info entity.inspect
        entities << entity
      end
      entities
    end

    def self.get_browse_node(elem, nodes, direction)
      node = {
          node_id: get_string_value(elem, "./BrowseNodeId"),
          node_name: get_string_value(elem, "./Name"),
      }

      node[:is_root] = true if get_string_value(elem, "./IsCategoryRoot").to_s == "1"
      nodes << node

      if exists_elem?(elem, direction)
        item.get_element(direction).get_element("BrowseNode")
        nodes = nodes | get_browse_node(elem, nodes, direction)
      end
      nodes
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