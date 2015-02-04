class Chatwork < Settingslogic
  source "#{Rails.root}/config/constants/chatwork.yml"
  namespace Rails.env
end
