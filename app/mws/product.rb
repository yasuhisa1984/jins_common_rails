class Product < Settingslogic
  source "#{Rails.root}/config/constants/mws_product.yml"
  namespace Rails.env
end