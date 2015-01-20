require 'happymapper'

module Amazon
  module MWS
    module FullfillmentInbound
      class CreateShipmentResult
        include HappyMapper

        tag 'CreateInboundShipmentResult'
        element :shipment_id, String, :tag => 'ShipmentId'
      end
    end
  end
end