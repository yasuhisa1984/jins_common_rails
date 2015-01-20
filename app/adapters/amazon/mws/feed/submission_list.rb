require 'happymapper'

module Amazon
  module MWS
    module Feed
      class SubmissionList
        include HappyMapper

        tag 'GetFeedSubmissionListResult'
        element :next_token, String, :tag => 'NextToken'
        element :has_next, Boolean, :tag => 'HasNext'
        has_many  :infos, Amazon::MWS::Feed::SubmissionInfo
      end
    end
  end
end