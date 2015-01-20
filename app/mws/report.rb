class Report < Settingslogic
  source "#{Rails.root}/config/constants/mws_report.yml"
  namespace Rails.env
end
