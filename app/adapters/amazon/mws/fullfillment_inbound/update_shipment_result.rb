require 'happymapper'

module Amazon
  module MWS
    module FullfillmentInbound
      class UpdateShipmentResult
        include HappyMapper

        tag 'UpdateInboundShipmentResult'
        element :shipment_id, String, :tag => 'ShipmentId'
      end
    end
  end
end