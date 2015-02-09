# encoding: utf-8
require "aws-sdk"
# require "aws_ec2_config"

class Amazon::SqsAdapter < Amazon::AwsAdapter

  def initialize(config={})
    @url = config.delete(:url)
    super config
  end

  def send_message(message)
    Rails.logger.debug "do send_message url=#{@url}, message:#{message}"
    create_client.queues[@url].send_message(message)
  end

  def poll_message(proc, timeout = 10)
    create_client.queues[@url].poll(:idle_timeout => timeout) do |msg|
      Rails.logger.debug "do proc_message url=#{@url}, message:#{msg.inspect}"
      proc.call msg
    end
  end
  
  def delete(message)
    create_client.queues[@url].delete message
  end

  private
  def create_client
    client = Aws::SQS.new
    client
  end
end