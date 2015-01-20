require 'happymapper'

module Amazon
  module MWS
    module Product
      class Product_list
        include HappyMapper

        tag 'Products'
        has_many :products, Product#, :xpath => "member"
      end
    end
  end
end