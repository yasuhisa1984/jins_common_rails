require 'happymapper'

module Amazon
  module MWS
    module Report
      class ReportRequestInfo
        include HappyMapper

        tag 'ReportRequestInfo'
        element :request_id, String, :tag => 'ReportRequestId'
        element :report_type, String, :tag => 'ReportType'
        element :scheduled, Boolean, :tag => 'Scheduled'
        element :start_date, DateTime, :tag => 'StartDate'
        element :end_date, DateTime, :tag => 'EndDate'
        element :completed_date, DateTime, :tag => 'CompletedDate'
        element :status, String, :tag => 'ReportProcessingStatus'
        element :report_id, String, :tag => 'GeneratedReportId'
      end
    end
  end
end