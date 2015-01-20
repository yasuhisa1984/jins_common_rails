require 'happymapper'

module Amazon
  module MWS
    module FullfillmentInbound
      class Item
        include HappyMapper

        tag 'member'
        element :seller_sku, String, :tag => 'SellerSKU'
        element :quantity, Integer, :tag => 'Quantity'
        element :fnsku, String, :tag => 'FulfillmentNetworkSKU'
      end
    end
  end
end