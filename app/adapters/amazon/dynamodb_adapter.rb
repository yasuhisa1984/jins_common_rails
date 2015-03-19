# encoding: utf-8
require "aws-sdk"
# require "aws_ec2_config"

class Amazon::DynamodbAdapter < Amazon::AwsAdapter

  def tables
    create_client.tables
  end

  def table(table_name)
    create_client.tables[table_name]
  end
  
  def batch_put(table_name, data_array)
    batch = create_batch
    
    data_array.each_slice(25).to_a.each do |limited_array|
      batch.put(table_name, limited_array)
      batch.process!
    end
  end

  private
  def create_client
    client = AWS::DynamoDB.new
    client
  end

  def create_batch
    client = AWS::DynamoDB::BatchWrite.new
    client
  end
end