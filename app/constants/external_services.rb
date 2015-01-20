module Const
  class ExternalService < Settingslogic
    source "#{Rails.root}/config/constants/external_service.yml"
    namespace Rails.env
  end
end
