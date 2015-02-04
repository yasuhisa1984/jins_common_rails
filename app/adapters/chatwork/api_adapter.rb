require "chatwork"

class Chatwork::ApiAdapter
  attr_accessor :api_key, :room_id
  
  def initialize(key, room_id)
    @api_key = key
    @room_id = room_id
    auth_client
  end
  
  def auth_client
    ChatWork.api_key = @api_key
  end
  
  def message(body)
    auth_client
    ChatWork::Message.create(room_id: @room_id, body: body)
  end
  
  def add_task(message, limit, *ids)
    p ids
    conn = get_connection
    
    response = conn.post do |request|
      request.url "/v1/rooms/#{@room_id}/tasks"
      request.headers = {
        'X-ChatWorkToken' => @api_key
      }
      request.params = {
        :body => message,
        :to_ids => ids.join(","),
      }
      
      request.body[:limit] = limit if limit.present?
      p request
    end
  end

  def get_me
    conn = get_connection
    response = conn.get do |request|
      request.url "/v1/me"
      request.headers = {
        'X-ChatWorkToken' => @api_key
      }
    end
    response
  end

  def get_members(room_id)
    conn = get_connection
    response = conn.get do |request|
      request.url "/v1/rooms/#{@room_id}/members"
      request.headers = {
        'X-ChatWorkToken' => @api_key
      }
    end
    response
  end

  def get_connection
    conn = Faraday::Connection.new(url: 'https://api.chatwork.com') do |builder|
      builder.use Faraday::Request::UrlEncoded
      builder.use Faraday::Response::Logger
      builder.use Faraday::Adapter::NetHttp
    end
    conn
  end

end