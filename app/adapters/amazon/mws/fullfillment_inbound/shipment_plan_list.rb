require 'happymapper'

module Amazon
  module MWS
    module FullfillmentInbound
      class ShipmentPlanList
        include HappyMapper

        tag 'InboundShipmentPlans'
        has_many :plans, ShipmentPlan#, :xpath => "member"
      end
    end
  end
end