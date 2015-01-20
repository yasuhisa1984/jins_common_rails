require 'happymapper'

module Amazon
  module MWS
    module Feed
      class SubmissionInfo
        include HappyMapper

        tag 'FeedSubmissionInfo'
        element :submission_id, String, :tag => 'FeedSubmissionId'
        element :feed_type, String, :tag => 'FeedType'
        element :submitted_date, DateTime, :tag => 'SubmittedDate'
        element :start_date, DateTime, :tag => 'StartedProcessingDate'
        element :completed_date, DateTime, :tag => 'CompletedProcessingDate'
        element :feed_processing_status, String, :tag => 'FeedProcessingStatus'
      end
    end
  end
end