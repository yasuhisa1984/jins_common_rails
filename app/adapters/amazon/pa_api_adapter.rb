require 'amazon/ecs'
class Amazon::PaApiAdapter
  attr_accessor :country
  
  def initialize()
    @country = "jp"
  end
  
  def self.configure_default
    api_key = Hayate::ApiKey.pa_api_default.first
    configure api_key
  end
  
  def self.configure(api_key = {})
    Amazon::Ecs.configure do |options|
      options[:associate_tag] = api_key.associate_tag
      options[:AWS_access_key_id] = api_key.access_key
      options[:AWS_secret_key] = api_key.secret_access_key
    end
  end

  def item_lookup_by_ean(item_ids = [], opts = {})
    opts[:id_type] = "EAN"
    opts[:search_index] = "All"
    self.item_lookup(item_ids, opts)
  end

  def item_lookup(item_ids = [], opts = {})
    opts[:country] ||= @country
    Amazon::Ecs.item_lookup(item_ids.join(","), opts)
  end

  def item_search(keyword, opts = {})
    opts[:country] ||= @country
    opts[:search_index] ||= "All"
    Amazon::Ecs.item_search(keyword.gsub(/\p{blank}/," "), opts)
  end
  
end