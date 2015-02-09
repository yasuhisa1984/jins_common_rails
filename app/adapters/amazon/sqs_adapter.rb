# encoding: utf-8
require "aws-sdk"
# require "aws_ec2_config"

class Amazon::SqsAdapter < Amazon::AwsAdapter

  def initialize(config={})
    @url = config.delete(:url)
    @client = AWS::SQS.new(config)
  end

  def send_message(message)
    Rails.logger.debug "do send_message url=#{@url}, message:#{message}"
    @client.queues[@url].send_message(message)
  end

  def poll_message(proc, timeout = 10)
    @client.queues[@url].poll(:idle_timeout => timeout) do |msg|
      Rails.logger.debug "do proc_message url=#{@url}, message:#{msg.inspect}"
      proc.call msg
    end
  end
  
  def delete(message)
    @client.queues[@url].delete message
  end

  private
  def create_client
    client = AWS::SQS.new
    client
  end
end