include HttpRequestHelper
class Yahoo::Jp::Shopping::ApiAdapter

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
    @agent.post(url, parameters, header)
    JSON.parse @agent.page.body
  end

  ## 商品管理APIセクション

  def myItemList(query="", stcat_key="", opt={})
    # 商品リストAPI
    parameter = merge_opts(@seller_id, opt)

    # 必須パラメータ
    parameter["query"] = query if query.present?
    parameter["stcat_key"] = stcat_key if stcat_key.present?

    begin
      @agent.get(
          "https://circus.shopping.yahooapis.jp/ShoppingWebService/V1/myItemList",
          parameter,
          nil,
          create_auth_header
      )
    rescue => e
      Rails.logger.error e.page.body
      raise e
    end

    xml_doc = @agent.page
    # puts @agent.page.body

    results = []
    xml_doc.search('//Result').each do |ret|
      next if ret.at('./ItemCode').blank?
      result = {
          item_code: ret.at('./ItemCode').text,
          has_sub_code: ret.at('./HasSubCode').text,
          name: ret.at('./Name/text()').text,
          st_cat_name: ret.at('./StCatName').text,
          display: ret.at('./Display').text,
          editing_flag: ret.at('./EditingFlag').text,
          original_price: ret.at('./OriginalPrice').text,
          price: ret.at('./Price').text,
          sale_price: ret.at('./SalePrice').text,
          sale_period_start: ret.at('./SalePeriodStart').text,
          sale_period_end: ret.at('./SalePeriodEnd').text,
          sort_order: ret.at('./SortOrder').text.to_i,
          condition: ret.at('./Condition').text.to_i,
      }
      result[:quantity] = ret.at('./Quantity').text.to_i if ret.at('./Quantity').present?

      results << result
    end

    results
  end

  def editItem(item)
    # 商品登録API
    parameter = merge_opts(@seller_id, item)
    begin
      Rails.logger.info parameter
      @agent = create_http_agent
      @agent.read_timeout = 3000000
      @agent.open_timeout = 3000000
      @agent.keep_alive = false

      @agent.post(
          "https://circus.shopping.yahooapis.jp/ShoppingWebService/V1/editItem",
          parameter,
          create_auth_header
      )
      sleep 5
    rescue Timeout::Error
      Rails.logger.warn "occur timeout! retry!"
      sleep 60
      retry # タイムアウトしちゃってもあきらめない！
    rescue Net::HTTP::Persistent::Error
      Rails.logger.warn "occur EOFError! retry!"
      sleep 60
      retry # タイムアウトしちゃってもあきらめない！
    rescue Mechanize::ResponseCodeError => e
      Rails.logger.error "#{e.response_code} - #{e.message}\n#{caller.join("\n")}"
      if e.respond_to?(:page)
        Rails.logger.error e.page.body
      end
      raise e
    end
  end

  def updateItems(items=[])
    # 商品一括更新API

    items.each_slice(100).to_a.each do |item_arr|
      counter = 1

      parameter = merge_opts(@seller_id, {})
      item_arr.each do |item|
        item_params = []

        item.each do |key, value|
          item_params << "#{key}=#{value}"
        end

        parameter["item#{counter}"] = URI.encode(item_params.join("&"))
        counter += 1
      end
      begin
        Rails.logger.info parameter
        @agent = create_http_agent
        @agent.read_timeout = 3000000
        @agent.open_timeout = 3000000
        @agent.keep_alive = false

        @agent.post(
            "https://circus.shopping.yahooapis.jp/ShoppingWebService/V1/updateItems",
            parameter,
            create_auth_header
        )
        sleep 5
      rescue Timeout::Error
        Rails.logger.warn "occur timeout! retry!"
        sleep 60
        retry # タイムアウトしちゃってもあきらめない！
      rescue Net::HTTP::Persistent::Error
        Rails.logger.warn "occur EOFError! retry!"
        sleep 60
        retry # タイムアウトしちゃってもあきらめない！
      rescue Mechanize::ResponseCodeError => e
        Rails.logger.error "#{e.response_code} - #{e.message}\n#{caller.join("\n")}"
        if e.respond_to?(:page)
          Rails.logger.error e.page.body
        end
        raise e
      end

    end
  end

  def moveItems
    # TODO 商品移動API
  end

  def sortItems
    # TODO 商品表示順序変更API
  end

  def getItem
    # TODO 商品参照API
  end

  def deleteItem
    # TODO 商品削除API
  end

  def submitItem
    # TODO 商品個別反映API
  end

  def uploadItemFile(file_path, type)
    # 商品アップロードAPI
    # 商品画像一括アップロードAPI
    st = File.stat(file_path)

    header = create_auth_header
    header["Content-Length"] = "#{st.size}"
    @agent = create_http_agent
    @agent.read_timeout = 300000
    @agent.open_timeout = 300000
    # @agent.keep_alive = false
    url = "https://circus.shopping.yahooapis.jp/ShoppingWebService/V1/uploadItemFile?seller_id=#{@seller_id}"

    begin
      @agent.post(url, {"file" => File.new(file_path),"type" => type}, header)
    rescue Mechanize::ResponseCodeError => e
      Rails.logger.error "#{e.response_code} - #{e.message}\n#{caller.join("\n")}"
      if e.respond_to?(:page)
        Rails.logger.error e.page.body
      end
      raise e
    rescue => ex
      Rails.logger.error "#{ex.class.name} - #{ex.message}\n#{caller.join("\n")}"
      retry # タイムアウトしちゃってもあきらめない！
    end
  end

  ## 在庫管理APIセクション
  def getStock
    # TODO 在庫参照API
  end

  def setStock(item_code=[], quantity=[], allow_overdraft)
    # 在庫更新API

    # 使用上の上限個数に分割する
    code_arrs = item_code.each_slice(1000).to_a
    quantity_arrs = quantity.each_slice(1000).to_a

    results = []
    begin
      index = 0
      code_arrs.each do |codes|
        quantities = quantity_arrs[index]

        # 必須パラメータ
        opts = {item_code: codes.join(','), quantity: quantities.join(',')}
        opts["allow_overdraft"] = allow_overdraft if allow_overdraft.present?
        parameter = merge_opts(@seller_id, opts)

        @agent.post(
            "https://circus.shopping.yahooapis.jp/ShoppingWebService/V1/setStock",
            parameter,
            create_auth_header
        )

        xml_doc = @agent.page
        puts @agent.page.body

        xml_doc.search('//Result').each do |ret|
          next if ret.at('./ItemCode').blank?
          result = {
              item_code: ret.at('./ItemCode').text,
              quantity: ret.at('./Quantity').text.to_i,
          }
          result[:quantity] = ret.at('./SubCode').text if ret.at('./SubCode').present?

          results << result
        end

        index += 1
        sleep 2
      end
    rescue Mechanize::ResponseCodeError => e
      Rails.logger.error "#{e.response_code} - #{e.message}\n#{caller.join("\n")}"
      if e.respond_to?(:page)
        Rails.logger.error e.page.body
      end
      raise e
    end

    results
  end

  def uploadStockFile
    # TODO 在庫アップロードAPI
  end

  ## 画像管理APIセクション

  ## 注文管理APIセクション
  def orderCount
    # 注文ステータス別件数参照API
    result = {}
    begin
      # 必須パラメータ
      parameter = merge_opts(@seller_id, {})

      @agent.get(
          "https://circus.shopping.yahooapis.jp/ShoppingWebService/V1/orderCount",
          parameter,
          nil,
          create_auth_header
      )

      xml_doc = @agent.page
      puts @agent.page.body

      result = {
          new_order: xml_doc.at('//Result/Count/NewOrder').text,
          new_reserve: xml_doc.at('//Result/Count/NewReserve').text,
      }
    rescue Mechanize::ResponseCodeError => e
      Rails.logger.error "#{e.response_code} - #{e.message}\n#{caller.join("\n")}"
      if e.respond_to?(:page)
        Rails.logger.error e.page.body
      end
      raise e
    end

    result
  end

  def orderList(condition={},fields=[],result_count=10,start=1,sort="+order_time")
    # 注文検索API
    result = {}
    begin
      # 必須パラメータ
      parameter = {
          "Req" => {
              "Search" => {
                  "Result" => result_count,
                  "Start" => start,
                  "Sort" => sort,
                  "Condition" => condition,
                  "Field" => fields.join(",")
              },
              "SellerId" => @seller_id
          }
      }

      req_xml = parameter.to_xml
      Rails.logger.debug req_xml
          # merge_opts(@seller_id, {})

      @agent.post(
          "https://circus.shopping.yahooapis.jp/ShoppingWebService/V1/orderList",
          req_xml,
          create_auth_header
      )

      xml_doc = @agent.page
      puts @agent.page.body

      result = {
          new_order: xml_doc.at('//Result/Count/NewOrder').text,
          new_reserve: xml_doc.at('//Result/Count/NewReserve').text,
      }
    rescue Mechanize::ResponseCodeError => e
      Rails.logger.error "#{e.response_code} - #{e.message}\n#{caller.join("\n")}"
      if e.respond_to?(:page)
        Rails.logger.error e.page.body
      end
      raise e
    end

    result
  end

  def orderInfo
    # TODO 注文詳細API
  end

  def orderStatusChange(order_id, status, update_user_name, fix_point=false)
    # TODO 注文ステータス変更API
    result = {}
    begin
      # 必須パラメータ
      parameter = {
          "Req" => {
              "Target" => {
                  "OrderId" => order_id,
                  "OperationUser" => update_user_name,
                  "IsPointFix" => fix_point.to_s,
                  "Order" => {
                      "OrderStatus" => status
                  }
              },
              "SellerId" => @seller_id
          }
      }

      req_xml = parameter.to_xml
      Rails.logger.debug req_xml
      # merge_opts(@seller_id, {})

      @agent.post(
          "https://circus.shopping.yahooapis.jp/ShoppingWebService/V1/orderStatusChange",
          req_xml,
          create_auth_header
      )

      xml_doc = @agent.page
      Rail.logger.info @agent.page.body

    rescue Mechanize::ResponseCodeError => e
      Rails.logger.error "#{e.response_code} - #{e.message}\n#{caller.join("\n")}"
      if e.respond_to?(:page)
        Rails.logger.error e.page.body
      end
      raise e
    end
  end

  def orderPayStatusChange
    # TODO 入金ステータス変更API
  end

  def orderShipStatusChange
    # TODO 出荷ステータス変更API
  end

  def orderChange
    # TODO 注文内容変更API
  end

  def orderChangeHistory
    # TODO 注文操作履歴一覧API
  end

  def orderSplit
    # TODO 注文分割API
  end

  def orderItemAdd
    # TODO 注文ライン追加API
  end

  def orderPayNumber(order_id, update_user_name)
    # 支払番号発行API
    result = {}
    begin
      # 必須パラメータ
      parameter = {
          "Req" => {
              "Target" => {
                  "OrderId" => order_id,
                  "OperationUser" => update_user_name,
              },
              "SellerId" => @seller_id
          }
      }

      req_xml = parameter.to_xml
      Rails.logger.debug req_xml
      # merge_opts(@seller_id, {})

      @agent.post(
          "https://circus.shopping.yahooapis.jp/ShoppingWebService/V1/orderPayNumber",
          req_xml,
          create_auth_header
      )

      xml_doc = @agent.page
      Rail.logger.info @agent.page.body

    rescue Mechanize::ResponseCodeError => e
      Rails.logger.error "#{e.response_code} - #{e.message}\n#{caller.join("\n")}"
      if e.respond_to?(:page)
        Rails.logger.error e.page.body
      end
      raise e
    end
  end

  def orderCouponCancel
    # TODO クーポンキャンセルAPI
  end

  def reservePublish(mode=1, reserve_time=nil)
    # 必須パラメータ
    opts={mode: mode}
    # オプション
    if reserve_time.present?
      opts[:reserve_time] = reserve_time.strftime("%Y%m%d%H%M")
    end
    parameter = merge_opts(@seller_id, opts)
    # 全反映予約API
    @agent = create_http_agent
    @agent.read_timeout = 300000
    @agent.open_timeout = 300000
    @agent.keep_alive = false
    @agent.post(
        "https://circus.shopping.yahooapis.jp/ShoppingWebService/V1/reservePublish",
        parameter,
        create_auth_header
    )
  end

  def uploadItemImagePack(file_path)
    # 商品画像一括アップロードAPI
    st = File.stat(file_path)

    header = create_auth_header
    header["Content-Length"] = "#{st.size}"
    @agent = create_http_agent
    @agent.read_timeout = 300000
    @agent.open_timeout = 300000
    # @agent.keep_alive = false
    url = "https://circus.shopping.yahooapis.jp/ShoppingWebService/V1/uploadItemImagePack?seller_id=#{@seller_id}"

    begin
      @agent.post(url, {"file" => File.new(file_path)}, header)
      # @agent.post(
      #     "https://circus.shopping.yahooapis.jp/ShoppingWebService/V1/uploadItemImagePack?seller_id=#{@seller_id}",
      #     File.open(file_path).read(st.size),
      #     create_auth_header
      # )
    # rescue Timeout::Error
    #   Rails.logger.warn "occur timeout! retry!"
    #   sleep 10
    #   retry # タイムアウトしちゃってもあきらめない！
    # rescue Net::HTTP::Persistent::Error
    #   Rails.logger.warn "occur EOFError! retry!"
    #   sleep 10
    #   retry # タイムアウトしちゃってもあきらめない！
    rescue Mechanize::ResponseCodeError => e
      Rails.logger.error "#{e.response_code} - #{e.message}\n#{caller.join("\n")}"
      if e.respond_to?(:page)
        Rails.logger.error e.page.body
      end
      raise e
    rescue => ex
      Rails.logger.error "#{ex.class.name} - #{ex.message}\n#{caller.join("\n")}"
      retry # タイムアウトしちゃってもあきらめない！
    end
  end

  private
  def create_auth_header
    header = {
        "Host" => "circus.shopping.yahooapis.jp",
        "Authorization" => "Bearer #{@auth_token}"
    }
  end

  def merge_opts(seller_id, opts={})
    parameter = {seller_id: @seller_id} if seller_id.present?
    parameter ||= {}

    if opts.present?
      opts.each do |key, val|
        parameter[key.to_s] = val
      end
    end
    parameter
  end

end