require 'happymapper'

module Amazon
  module MWS
    module Report
      class ReportRequestList
        include HappyMapper

        tag 'GetReportRequestListResult'
        element :next_token, String, :tag => 'NextToken'
        element :has_next, Boolean, :tag => 'HasNext'
        has_many  :infos, Amazon::MWS::Report::ReportRequestInfo
      end
    end
  end
end