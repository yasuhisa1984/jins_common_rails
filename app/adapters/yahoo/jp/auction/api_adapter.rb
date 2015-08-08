include HttpRequestHelper
class Yahoo::Jp::Auction::ApiAdapter

  def initialize(opt={})
    @auth_token = opt[:auth_token]
    @seller_id = opt[:account_id]

    @agent = create_http_agent
  end

  def do_refresh_token(client_id, secret, refresh_token)
    url = "https://auth.login.yahoo.co.jp/yconnect/v1/token"

    basic_auth = Base64::strict_encode64("#{client_id}:#{secret}").strip

    header = {
        "Content-Type" => "application/x-www-form-urlencoded",
        'Expect'=> '' ,
        "Authorization" => "Basic #{basic_auth}"
    }
    parameters = {
        "grant_type" => "refresh_token",
        "refresh_token" => refresh_token,
        # "client_id" => client_id,
    }

    Rails.logger.debug "POST #{url}, #{parameters}, #{header}"
    begin
      @agent.post(url, parameters, header)
    rescue Mechanize::ResponseCodeError => e
      Rails.logger.error "#{e.response_code} - #{e.message}\n#{caller.join("\n")}"
      if e.respond_to?(:page)
        Rails.logger.error e.page.body
      end
      raise e
    end
    JSON.parse @agent.page.body
  end

  ## 商品管理APIセクション

  def mySellingList(start=1,output=:xml)
    parameter = {}

    # 必須パラメータ
    parameter["start"] = start
    parameter["output"] = output

    begin
      @agent.get(
          "https://auctions.yahooapis.jp/AuctionWebService/V2/mySellingList",
          parameter,
          nil,
          create_auth_header
      )
    rescue Mechanize::ResponseCodeError => e
      Rails.logger.error "#{e.response_code} - #{e.message}\n#{caller.join("\n")}"
      if e.respond_to?(:page)
        Rails.logger.error e.page.body
      end
      raise e
    end

    xml_doc = Nokogiri::XML(@agent.page.body)
    xml_doc.remove_namespaces!

    result_set = xml_doc.at('//ResultSet')
    res = {
        availables: result_set.attribute('totalResultsAvailable').value.to_i,
        returned:  result_set.attribute('totalResultsReturned').value.to_i,
        position: result_set.attribute('firstResultPosition').value.to_i
    }

    results = []
    xml_doc.search('//Result').each do |ret|
      next if ret.at('./AuctionID').blank?
      result = {
          auction_id: ret.at('./AuctionID').text,
          title: ret.at('./Title').text,
          price: ret.at('./CurrentPrice').text.to_i,
          bids: ret.at('./Bids').text.to_i,
          num_watch: ret.at('./NumWatch').text.to_i,
          has_offer: ret.at('./HasOffer').text,
      }
      if ret.at('./Option/IsTradingNaviAuction').present?
        result[:is_trading_navi] = ret.at('./Option/IsTradingNaviAuction').text
      end

      results << result
    end


    res[:results] = results
    res
  end

  # list	string	sold ： 落札者ありの一覧を表示します。
  # not_sold ： 落札者なしの一覧を表示します。
  def myCloseList(start=1,output=:xml,list=:sold)
    # マイ・オークション表示（出品終了分）
    parameter = {}

    # 必須パラメータ
    parameter["start"] = start
    parameter["output"] = output
    parameter["list"] = list

    begin
      @agent.get(
          "https://auctions.yahooapis.jp/AuctionWebService/V2/myCloseList",
          parameter,
          nil,
          create_auth_header
      )
    rescue Mechanize::ResponseCodeError => e
      Rails.logger.error "#{e.response_code} - #{e.message}\n#{caller.join("\n")}"
      if e.respond_to?(:page)
        Rails.logger.error e.page.body
      end
      raise e
    end

    xml_doc = Nokogiri::XML(@agent.page.body)
    xml_doc.remove_namespaces!

    result_set = xml_doc.at('//ResultSet')
    res = {
        availables: result_set.attribute('totalResultsAvailable').value.to_i,
        returned:  result_set.attribute('totalResultsReturned').value.to_i,
        position: result_set.attribute('firstResultPosition').value.to_i

    }

    results = []
    xml_doc.search('//Result').each do |ret|
      next if ret.at('./AuctionID').blank?
      result = {
          auction_id: ret.at('./AuctionID').text,
          title: ret.at('./Title').text,
          highest_price: ret.at('./HighestPrice').text.to_i,
          has_offer: ret.at('./Option/HasOffer').text,
          is_trading_navi: ret.at('./Option/IsTradingNaviAuction').text,
          winner_id: ret.at('./Winner/Id').text,
      }
      if ret.at('./Option/IsTradingNaviAuction').present?
        result[:is_trading_navi] = ret.at('./Option/IsTradingNaviAuction').text
      end
      if ret.at('./Message/Title').present?
        result[:message] = ret.at('./Message/Title').text
      end

      results << result
    end


    res[:results] = results
    res
  end
  
  def myWinnerList(auction_id)
    # マイ・オークション表示（出品終了分）
    parameter = {}

    # 必須パラメータ
    parameter["auctionid"] = auction_id
    parameter["output"] = :xml

    begin
      @agent.get(
          "https://auctions.yahooapis.jp/AuctionWebService/V1/myWinnerList",
          parameter,
          nil,
          create_auth_header
      )
    rescue Mechanize::ResponseCodeError => e
      Rails.logger.error "#{e.response_code} - #{e.message}\n#{caller.join("\n")}"
      if e.respond_to?(:page)
        Rails.logger.error e.page.body
      end
      raise e
    end

    xml_doc = Nokogiri::XML(@agent.page.body)
    xml_doc.remove_namespaces!

    result_set = xml_doc.at('//ResultSet')
    res = {
        availables: result_set.attribute('totalResultsAvailable').value.to_i,
        returned:  result_set.attribute('totalResultsReturned').value.to_i,
        position: result_set.attribute('firstResultPosition').value.to_i

    }

    results = []
    xml_doc.search('//Result').each do |ret|
      next if ret.at('./AuctionID').blank?
      
      ret.search('./HighestBidders/Bidder').each do |bidder|
        result = {
            auction_id: ret.at('./AuctionID').text,
            title: ret.at('./Title').text,
            end_time: Time.parse(ret.at('./EndTime').text),
            winner_id: bidder.at('./Id').text,
            highest_price: bidder.at('./HighestPrice').text.gsub(",","").to_i,
            progress: bidder.at('./Progress').text,
        }
  
        results << result
      end
    end

    res[:results] = results
    res
  end

  private
  def create_auth_header
    header = {
        "Authorization" => "Bearer #{@auth_token}"
    }
  end

end