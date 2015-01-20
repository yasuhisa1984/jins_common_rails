class Aws < Settingslogic
  source "#{Rails.root}/config/constants/aws.yml"
  namespace Rails.env
end
