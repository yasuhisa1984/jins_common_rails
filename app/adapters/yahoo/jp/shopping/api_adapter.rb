include HttpRequestHelper
class Yahoo::Jp::Shopping::ApiAdapter

  def initialize(opt={})
    @auth_token = opt[:auth_token]
    @seller_id = opt[:account_id]

    @agent = create_http_agent
  end

  def do_refresh_token(client_id, secret, refresh_token)
    url = "https://auth.login.yahoo.co.jp/yconnect/v1/token"

    basic_auth = Base64.encode64 "#{client_id}:#{secret}"

    header = {
        "Content-Type" => "application/x-www-form-urlencoded",
        "Authorization" => "Basic #{basic_auth}"
    }
    parameters = {
        "grant_type" => "refresh_token",
        "refresh_token" => refresh_token,
        "client_id" => client_id,
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

  def editItem
    # TODO 商品登録API
  end

  def updateItems
    # TODO 商品一括更新API
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

  def uploadItemFile
    # TODO 商品アップロードAPI
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
    rescue => e
      Rails.logger.error e.page.body
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
    rescue => e
      Rails.logger.error e.page.body
      raise e
    end

    result
  end

  def orderList
    # TODO 注文検索API
  end

  def orderInfo
    # TODO 注文詳細API
  end

  def orderStatusChange
    # TODO 注文ステータス変更API
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

  def orderPayNumber
    # TODO 支払番号発行API
  end

  def orderCouponCancel
    # TODO クーポンキャンセルAPI
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