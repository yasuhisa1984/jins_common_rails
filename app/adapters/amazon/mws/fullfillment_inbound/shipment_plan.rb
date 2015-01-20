require 'happymapper'

module Amazon
  module MWS
    module FullfillmentInbound
      class Items
        include HappyMapper

        tag 'Items'
        # has_many :members, Item
      end

      class ShipToAddress
        include HappyMapper

        tag 'ShipToAddress'
        element :postal_code, String, :tag => 'PostalCode'
        element :name, String, :tag => 'Name'
        element :country_code, DateTime, :tag => 'CountryCode'
        element :district_or_county, DateTime, :tag => 'DistrictOrCounty'
        element :state_or_province_code, DateTime, :tag => 'StateOrProvinceCode'
        element :address_line1, String, :tag => 'AddressLine1'
        element :address_line2, String, :tag => 'AddressLine2'
        element :city, String, :tag => 'City'
      end

      class ShipFromAddress
        include HappyMapper

        tag 'ShipFromAddress'
        element :postal_code, String, :tag => 'PostalCode'
        element :name, String, :tag => 'Name'
        element :country_code, DateTime, :tag => 'CountryCode'
        element :district_or_county, DateTime, :tag => 'DistrictOrCounty'
        element :state_or_province_code, DateTime, :tag => 'StateOrProvinceCode'
        element :address_line1, String, :tag => 'AddressLine1'
        element :address_line2, String, :tag => 'AddressLine2'
        element :city, String, :tag => 'City'
      end
      
      class ShipmentPlan
        include HappyMapper

        tag 'member'
        element :shipment_id, String, :tag => 'ShipmentId'
        element :label_prep_type, String, :tag => 'LabelPrepType'
        element :center_id, DateTime, :tag => 'DestinationFulfillmentCenterId'
        has_one :ship_to_address, Amazon::MWS::FullfillmentInbound::ShipToAddress
        has_many :items, Amazon::MWS::FullfillmentInbound::Item
        
        def get_item_sku_map
          if @map.blank?
            @map = {}
            self.items.each do |item|
              @map[item.seller_sku] = item
            end
          end
          @map
        end
      end
    end
  end
end