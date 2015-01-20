class PaApi < Settingslogic
  source "#{Rails.root}/config/constants/pa_api.yml"
  namespace Rails.env
end
