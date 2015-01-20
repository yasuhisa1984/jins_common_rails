require 'google/api_client'

class Google::ApiAdapter
  
  def initialize
    @client = self.create_base_client
    @printer_client = self.create_base_printer_client
  end

  def get_client
    @client
  end

  def setup_authorized_client(client)
    @client = client
  end

  def setup_with_token(token)
    @client.authorization.update_token!(token.to_hash)
    @printer_client.refresh_token = token.refresh_token
  end

  def get_profile
    @profile = nil
    if @client.authorization.access_token.present?
      result = @client.execute(:uri => 'https://www.googleapis.com/oauth2/v1/userinfo')    
      @profile = JSON.parse result.response.body
      @profile.symbolize_keys!
    end
    @profile
  end
  
  def get_printers_all
    @printer_client.printers.all
  end
  
  def get_printer(printer_id)
    @printer_client.printers.find(printer_id)
  end

  def create_base_client
    @client = Google::APIClient.new(
      :application_name => 'Hayate Express Tools',
      :application_version => '0.0.1'
    )
    @client.authorization.client_id = Constants::ExternalApi.google.client_id
    @client.authorization.client_secret = Constants::ExternalApi.google.client_secret
    @client.authorization.scope = "profile https://www.googleapis.com/auth/cloudprint"
    @client.authorization.redirect_uri = Constants::ExternalApi.google.redirect_uri
    @client
  end
  
  def create_base_printer_client
    @printer_client = CloudPrint::Client.new(
      client_id: Constants::ExternalApi.google.client_id,
      client_secret: Constants::ExternalApi.google.client_secret,
      callback_url: Constants::ExternalApi.google.redirect_uri
    )
    @printer_client
  end

end