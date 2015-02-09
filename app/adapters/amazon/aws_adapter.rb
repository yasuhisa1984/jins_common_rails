# encoding: utf-8
require "aws-sdk"
# require "aws_ec2_config"

class Amazon::AwsAdapter
  def initialize(config={})
    Rails.logger.info config
    Aws.config(config)
  end
end