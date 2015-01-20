class Feed < Settingslogic
  source "#{Rails.root}/config/constants/mws_feed.yml"
  namespace Rails.env
end
