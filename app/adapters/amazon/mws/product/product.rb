require 'happymapper'

module Amazon
  module MWS
    module Product
      class Product
        include HappyMapper

        tag 'Product'
        #has_one :identifier, Identifier
        # has_one :attribute_set, AttributeSets
      end
      
      # class AttributeSets
        # include HappyMapper
        # register_namespace "n2", "http://mws.amazonservices.com/schema/Products/2011-10-01/default.xsd"
# 
        # tag 'AttributeSets'
        # has_one :item_attribute, ItemAttribute
        # has_one :attribute_set, AttributeSets
      # end
    end
  end
end