require 'peddler'
require 'rexml/document'

require 'uri'
require 'time'
require 'openssl'
require 'base64'
require "net/https"

class Amazon::MwsAdapter
  attr_accessor :country

  def initialize(opt={})
    @country = "jp"
    @marketplace_id = opt[:marketplace_id]
    @merchant_id = opt[:merchant_id]
    @access_key_id = opt[:access_key_id]
    @secret_access_key = opt[:secret_access_key]
    @auth_token = opt[:auth_token] if opt[:auth_token].present?
  end

  def valid?
    ret = false
    begin
      self.get_report_request_count
    rescue
      #例外が起きた場合の処理
    else
      #例外が発生しなかった場合の処理
      ret = true
    end
  end

  # ==== Product API Section ====

  # Lists products and their attributes, based on a search query
  #
  # @see http://docs.developer.amazonservices.com/en_US/products/Products_ListMatchingProducts.html
  # @overload list_matching_products(query, opts = { marketplace_id: marketplace_id })
  #   @param query [String]
  #   @param opts [Hash]
  #   @option opts [String] :marketplace_id
  #   @option opts [String] :query_context_id
  # @return [Peddler::XMLParser]
  def list_matching_products(query, opts = {})
    begin
      return get_product_client.list_matching_products(query, opts)
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Lists products and their attributes, based on a list of ASIN, GCID,
  #   SellerSKU, UPC, EAN, ISBN, and JAN values
  #
  # @see http://docs.developer.amazonservices.com/en_US/products/Products_GetMatchingProduct.html
  # @overload get_matching_product_for_id(id_type, *id_list, opts = { marketplace_id: marketplace_id })
  #   @param id_type [String]
  #   @param id_list [Array<String>]
  #   @param opts [Hash]
  #   @option opts [String] :marketplace_id
  # @return [Peddler::XMLParser]
  def get_matching_product_for_id(id_type, id_list)
    begin
      return get_product_client.get_matching_product_for_id(id_type, *id_list)
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Lists products and their attributes, based on a list of ASIN values
  #
  # @see http://docs.developer.amazonservices.com/en_US/products/Products_GetMatchingProductForId.html
  # @overload get_matching_product(*asins, opts = { marketplace_id: marketplace_id })
  #   @param asins [Array<String>]
  #   @param opts [Hash]
  #   @option opts [String] :marketplace_id
  # @return [Peddler::XMLParser]
  def get_matching_product(asins)
    begin
      return get_product_client.get_matching_product(*asins)
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Gets the current competitive price of a product, based on Seller SKU
  #
  # @see http://docs.developer.amazonservices.com/en_US/products/Products_GetCompetitivePricingForSKU.html
  # @overload get_competitive_pricing_for_sku(*skus, opts = { marketplace_id: marketplace_id })
  #   @param skus [Array<String>]
  #   @param opts [Hash]
  #   @option opts [String] :marketplace_id
  # @return [Peddler::XMLParser]
  def get_competitive_pricing_for_sku(skus)
    begin
      return get_product_client.get_competitive_pricing_for_sku(*skus)
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Gets the current competitive price of a product, identified by its ASIN
  #
  # @see http://docs.developer.amazonservices.com/en_US/products/Products_GetCompetitivePricingForASIN.html
  # @overload get_competitive_pricing_for_asin(*asins, opts = { marketplace_id: marketplace_id })
  #   @param asins [Array<String>]
  #   @param opts [Hash]
  #   @option opts [String] :marketplace_id
  # @return [Peddler::XMLParser]
  def get_competitive_pricing_for_asin(asins)
    begin
      return get_product_client.get_competitive_pricing_for_asin(*asins)
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Gets pricing information for the lowest-price active offer listings for
  # a product, based on Seller SKU
  #
  # @see http://docs.developer.amazonservices.com/en_US/products/Products_GetLowestOfferListingsForSKU.html
  # @overload get_lowest_offer_listings_for_sku(*skus, opts = { marketplace_id: marketplace_id })
  #   @param skus [Array<String>]
  #   @param opts [Hash]
  #   @option opts [String] :marketplace_id
  #   @option opts [String] :item_condition
  #   @option opts [Boolean] :exclude_me
  # @return [Peddler::XMLParser]
  def get_lowest_offer_listings_for_sku(skus)
    begin
      return get_product_client.get_lowest_offer_listings_for_sku(*skus)
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Gets pricing information for the lowest-price active offer listings for
  # a product, identified by its ASIN
  #
  # @see http://docs.developer.amazonservices.com/en_US/products/Products_GetLowestOfferListingsForASIN.html
  # @overload get_lowest_offer_listings_for_asin(*asins, opts = { marketplace_id: marketplace_id })
  #   @param asins [Array<String>]
  #   @param opts [Hash]
  #   @option opts [String] :marketplace_id
  #   @option opts [String] :item_condition
  #   @option opts [Boolean] :exclude_me
  # @return [Peddler::XMLParser]
  def get_lowest_offer_listings_for_asin(asins)
    begin
      return get_product_client.get_lowest_offer_listings_for_asin(*asins)
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Gets pricing information for seller's own offer listings, based on
  # Seller SKU
  #
  # @see http://docs.developer.amazonservices.com/en_US/products/Products_GetMyPriceForSKU.html
  # @overload get_my_price_for_sku(*skus, opts = { marketplace_id: marketplace_id })
  #   @param skus [Array<String>]
  #   @param opts [Hash]
  #   @option opts [String] :marketplace_id
  #   @option opts [String] :item_condition
  # @return [Peddler::XMLParser]
  def get_my_price_for_sku(skus)
    begin
      return get_product_client.get_my_price_for_sku(*skus)
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Gets pricing information for seller's own offer listings, identified by
  # its ASIN
  #
  # @see http://docs.developer.amazonservices.com/en_US/products/Products_GetMyPriceForASIN.html
  # @overload get_my_price_for_asin(*skus, opts = { marketplace_id: marketplace_id })
  #   @param asins [Array<String>]
  #   @param opts [Hash]
  #   @option opts [String] :marketplace_id
  #   @option opts [String] :item_condition
  # @return [Peddler::XMLParser]
  def get_my_price_for_asin(asins)
    begin
      return get_product_client.get_my_price_for_asin(*asins)
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Gets parent product categories that a product belongs to, based on
  # Seller`SKU
  #
  # @see http://docs.developer.amazonservices.com/en_US/products/Products_GetProductCategoriesForSKU.html
  # @overload get_product_categories_for_sku(sku, opts = { marketplace_id: marketplace_id })
  #   @param sku [String]
  #   @param opts [Hash]
  #   @option opts [String] :marketplace_id
  # @return [Peddler::XMLParser]
  def get_product_categories_for_sku(sku, opts = {})
    begin
      return get_product_client.get_product_categories_for_sku(sku, opts)
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Gets parent product categories that a product belongs to, based on ASIN
  #
  # @see http://docs.developer.amazonservices.com/en_US/products/Products_GetProductCategoriesForASIN.html
  # @overload get_product_categories_for_asin(asin, opts = { marketplace_id: marketplace_id })
  #   @param asin [String]
  #   @param opts [Hash]
  #   @option opts [String] :marketplace_id
  # @return [Peddler::XMLParser]
  def get_product_categories_for_asin(asin, opts = {})
    begin
      return get_product_client.get_product_categories_for_asin(asin, opts)
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # ==== Feed API Section ====

  # Uploads a feed
  #
  # @note Feed size is limited to 2,147,483,647 bytes (2^31 -1) per feed
  # @see http://docs.developer.amazonservices.com/en_US/feeds/Feeds_SubmitFeed.html
  # @see http://docs.developer.amazonservices.com/en_US/feeds/Feeds_FeedType.html
  # @param feed_content [String] an XML or flat file feed
  # @param feed_type [String] the feed type
  # @param opts [Hash]
  # @option opts [Array<String>, String] :marketplace_id_list
  # @option opts [Boolean] :purge_and_replace
  # @return [Peddler::XMLParser]
  def submit_feed(feed_content, feed_type, opts = {})
    begin
      res = get_feed_client.submit_feed(feed_content, feed_type, opts)
      info = Amazon::MWS::Feed::SubmissionInfo.parse(
          res.data[:body], :single => true, :use_default_namespace => true)

      return info
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # List feed submissions
  #
  # @see http://docs.developer.amazonservices.com/en_US/feeds/Feeds_GetFeedSubmissionList.html
  # @see http://docs.developer.amazonservices.com/en_US/feeds/Feeds_FeedType.html
  # @param opts [Hash]
  # @option opts [Array<String>, String] :feed_submission_id_list
  # @option opts [Integer] :max_count
  # @option opts [Array<String>, String] :feed_type_list
  # @option opts [Array<String>, String] :feed_processing_status_list
  # @option opts [String, #iso8601] :submitted_from_date
  # @option opts [String, #iso8601] :submitted_to_date
  # @return [Peddler::XMLParser]Ï
  def get_feed_submission_list(opts = {})
    begin
      res = get_feed_client.get_feed_submission_list(opts)
      res_list = Amazon::MWS::Feed::SubmissionList.parse(res.data[:body], :single => true, :use_default_namespace => true)

      return res_list
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Gets the processing report for a feed and its Content-MD5 header
  #
  # @see http://docs.developer.amazonservices.com/en_US/feeds/Feeds_GetFeedSubmissionResult.html
  # @param feed_submission_id [Integer, String]
  # @return [Peddler::XMLParser] if the report is in XML format
  # @return [Peddler::CSVParser] if the report is a flat file
  def get_feed_submission_result(feed_submission_id)
    begin
      return get_feed_client.get_feed_submission_result(feed_submission_id)
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Creates a report request
  #
  # @see http://docs.developer.amazonservices.com/en_US/reports/Reports_RequestReport.html
  # @param report_type [String]
  # @param opts [Hash]
  # @option opts [String, #iso8601] :start_date
  # @option opts [String, #iso8601] :end_date
  # @option opts [String] :report_options
  # @option opts [Array<String>, String] :marketplace_id
  # @return [Peddler::XMLParser]
  def request_report(report_type, opts = {})
    begin
      res = get_report_client.request_report(report_type, opts)
      info = Amazon::MWS::Report::ReportRequestInfo.parse(
          res.data[:body], :single => true, :use_default_namespace => true)
      return info
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Lists report requests
  #
  # @see http://docs.developer.amazonservices.com/en_US/reports/Reports_GetReportRequestList.html
  # @param opts [Hash]
  # @option opts [Array<String>, String] :report_request_id_list
  # @option opts [Array<String>, String] :report_type_list
  # @option opts [Array<String>, String] :report_processing_status_list
  # @option opts [Integer] :max_count
  # @option opts [String, #iso8601] :requested_from_date
  # @option opts [String, #iso8601] :requested_to_date
  # @return [Peddler::XMLParser]
  def get_report_request_list(opts = {})
    begin
      return get_report_client.get_report_request_list(opts)
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Lists the next page of the report requests
  #
  # @see http://docs.developer.amazonservices.com/en_US/reports/Reports_GetReportRequestListByNextToken.html
  # @param next_token [String]
  # @return [Peddler::XMLParser]
  def get_report_request_list_by_next_token(next_token)
    begin
      return get_report_client.get_report_request_list_by_next_token next_token
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Counts requested reports
  #
  # @see http://docs.developer.amazonservices.com/en_US/reports/Reports_GetReportRequestCount.html
  # @param opts [Hash]
  # @option opts [Array<String>, String] :report_type_list
  # @option opts [Array<String>, String] :report_processing_status_list
  # @option opts [String, #iso8601] :requested_from_date
  # @option opts [String, #iso8601] :requested_to_date
  # @return [Peddler::XMLParser]
  def get_report_request_count(opts = {})
    begin
      return get_report_client.get_report_request_count opts
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Cancels one or more report requests
  #
  # @see http://docs.developer.amazonservices.com/en_US/reports/Reports_CancelReportRequests.html
  # @param opts [Hash]
  # @option opts [Array<String>, String] :report_type_list
  # @option opts [Array<String>, String] :report_processing_status_list
  # @option opts [String, #iso8601] :requested_from_date
  # @option opts [String, #iso8601] :requested_to_date
  # @return [Peddler::XMLParser]
  def cancel_report_requests(opts = {})
    begin
      return get_report_client.cancel_report_requests opts
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Lists reports
  #
  # @see http://docs.developer.amazonservices.com/en_US/reports/Reports_GetReportList.html
  # @param opts [Hash]
  # @option opts [Integer] :max_count
  # @option opts [Array<String>, String] :report_type_list
  # @option opts [Boolean] :acknowledged
  # @option opts [String, #iso8601] :available_from_date
  # @option opts [String, #iso8601] :available_to_date
  # @option opts [Array<String>, String] :report_request_id_list
  # @return [Peddler::XMLParser]
  def get_report_list(opts = {})
    begin
      return get_report_client.get_report_list opts
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Lists the next page of reports
  #
  # @see http://docs.developer.amazonservices.com/en_US/reports/Reports_GetReportListByNextToken.html
  # @param next_token [String]
  # @return [Peddler::XMLParser]
  def get_report_list_by_next_token(next_token)
    begin
      return get_report_client.get_report_list_by_next_token next_token
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Counts reports
  #
  # @see http://docs.developer.amazonservices.com/en_US/reports/Reports_GetReportCount.html
  # @param opts [Hash]
  # @option opts [Array<String>, String] :report_type_list
  # @option opts [Boolean] :acknowledged
  # @option opts [String, #iso8601] :available_from_date
  # @option opts [String, #iso8601] :available_to_date
  # @return [Peddler::XMLParser]
  def get_report_count(opts = {})
    begin
      return get_report_client.get_report_count opts
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Gets a report and its Content-MD5 header
  #
  # @see http://docs.developer.amazonservices.com/en_US/reports/Reports_GetReport.html
  # @param report_id [String]
  # @return [Peddler::XMLParser] if report is in XML format
  # @return [Peddler::CSVParser] if report is a flat file
  def get_report(report_id, &blk)
    begin
      return get_report_client.get_report(report_id)
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
    # mws = MWS.new(
    # :aws_access_key_id => @access_key_id,
    # :secret_access_key => @secret_access_key,
    # :seller_id => @merchant_id,
    # :marketplace_id => @marketplace_id
    # )
    # mws.reports.get_report :report_id => report_id
  end

  # Creates, updates, or deletes a report request schedule
  #
  # @see http://docs.developer.amazonservices.com/en_US/reports/Reports_ManageReportSchedule.html
  # @param report_type [String]
  # @param schedule [String]
  # @param opts [Hash]
  # @option opts [String, #iso8601] :schedule_date
  # @return [Peddler::XMLParser]
  def manage_report_schedule(report_type, schedule, opts = {})
    begin
      return get_report_client.manage_report_schedule(report_type, schedule, opts)
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # List scheduled reports
  #
  # @see http://docs.developer.amazonservices.com/en_US/reports/Reports_GetReportScheduleList.html
  # @param report_type_list [*Array<String>]
  # @return [Peddler::XMLParser]
  def get_report_schedule_list(*report_type_list)
    get_report_client.get_report_schedule_list report_type_list
  end

  # List next page of scheduled reports
  #
  # @see http://docs.developer.amazonservices.com/en_US/reports/Reports_GetReportScheduleListByNextToken.html
  # @param next_token [String]
  # @raise [NotImplementedError]
  def get_report_schedule_list_by_next_token(next_token)
    begin
      return get_report_client.get_report_schedule_list_by_next_token next_token
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Count scheduled reports
  #
  # @see http://docs.developer.amazonservices.com/en_US/reports/Reports_GetReportScheduleCount.html
  # @param report_type_list [Array<String>]
  # @return [Peddler::XMLParser]
  def get_report_schedule_count(*report_type_list)
    begin
      return get_report_client.get_report_schedule_count report_type_list
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Update acknowledged status of one or more reports
  #
  # @see http://docs.developer.amazonservices.com/en_US/reports/Reports_UpdateReportAcknowledgements.html
  # @param acknowledged [Boolean]
  # @param report_id_list [Array<String>]
  # @return [Peddler::XMLParser]
  def update_report_acknowledgements(acknowledged, *report_id_list)
    begin
      return get_report_client.update_report_acknowledgements(acknowledged, report_id_list)
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Returns the information required to create an inbound shipment
  #
  # @see http://docs.developer.amazonservices.com/en_US/fba_inbound/FBAInbound_CreateInboundShipmentPlan.html
  # @param ship_from_address [Struct, Hash]
  # @param inbound_shipment_plan_request_items [Array<Struct, Hash>]
  # @param opts [Hash]
  # @option opts [String] :label_prep_preference
  # @return [Peddler::XMLParser]
  def create_inbound_shipment_plan(ship_from_address, inbound_shipment_plan_request_items, opts = {})
    begin
      res = get_inbound_shipment_client.create_inbound_shipment_plan(ship_from_address, inbound_shipment_plan_request_items, opts)
      info = Amazon::MWS::FullfillmentInbound::ShipmentPlanList.parse(res.data[:body], :single => true, :use_default_namespace => true)
      Rails.logger.info info
      plans = []
      info.plans.each { |plan| plans << plan if plan.shipment_id.present? }

      return plans
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
    # res = do_create_inbound_shipment_plan(ship_from_address, inbound_shipment_plan_request_items)
    # info = Amazon::MWS::FullfillmentInbound::ShipmentPlanList.parse(res, :single => true, :use_default_namespace => true)
  end

  # Creates an inbound shipment
  #
  # @see http://docs.developer.amazonservices.com/en_US/fba_inbound/FBAInbound_CreateInboundShipment.html
  # @param shipment_id [String]
  # @param inbound_shipment_header [Struct, Hash]
  # @param opts [Hash]
  # @option opts [Array<Struct, Hash>] :inbound_shipment_items
  # @return [Peddler::XMLParser]
  def create_inbound_shipment(shipment_id, inbound_shipment_header, opts = {})
    begin
      res = get_inbound_shipment_client.create_inbound_shipment(shipment_id, inbound_shipment_header, opts)
      Rails.logger.info res.data[:body]
      info = Amazon::MWS::FullfillmentInbound::CreateShipmentResult.parse(res.data[:body], :single => true, :use_default_namespace => true)

      Rails.logger.debug info.inspect
      return info
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
    # 暫定対応版
    # res = do_inbound_shipment(shipment_id, inbound_shipment_header, opts, "CreateInboundShipment")
    # info = Amazon::MWS::FullfillmentInbound::CreateShipmentResult.parse(res, :single => true, :use_default_namespace => true)
  end

  # Updates an existing inbound shipment
  #
  # @see http://docs.developer.amazonservices.com/en_US/fba_inbound/FBAInbound_UpdateInboundShipment.html
  # @param shipment_id [String]
  # @param inbound_shipment_header [Struct, Hash]
  # @param opts [Hash]
  # @option opts [Array<Struct, Hash>] :inbound_shipment_items
  # @return [Peddler::XMLParser]
  def update_inbound_shipment(shipment_id, inbound_shipment_header, opts = {})
    begin
      # res = do_inbound_shipment(shipment_id, inbound_shipment_header, opts, "UpdateInboundShipment")
      # info = Amazon::MWS::FullfillmentInbound::UpdateShipmentResult.parse(res, :single => true, :use_default_namespace => true)

      res = get_inbound_shipment_client.update_inbound_shipment(shipment_id, inbound_shipment_header, opts)
      Rails.logger.info res.data[:body]
      info = Amazon::MWS::FullfillmentInbound::UpdateShipmentResult.parse(res.data[:body], :single => true, :use_default_namespace => true)
      Rails.logger.debug info.inspect
      return info
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
    # 暫定対応版
  end

  # Returns a list of inbound shipments based on criteria that you specify
  #
  # @see http://docs.developer.amazonservices.com/en_US/fba_inbound/FBAInbound_ListInboundShipments.html
  # @param opts [Hash]
  # @option opts [Array<String>] :shipment_status_list
  # @option opts [Array<String>] :shipment_id_list
  # @option opts [String, #iso8601] :last_updated_after
  # @option opts [String, #iso8601] :last_updated_before
  # @return [Peddler::XMLParser]
  def list_inbound_shipments(opts = {})
    begin
      res = get_inbound_shipment_client.list_inbound_shipments(opts)
      Rails.logger.info res.data[:body]
      return res.data[:body]
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Returns a list of items in a specified inbound shipment, or a list of
  # items that were updated within a specified time frame
  #
  # @see http://docs.developer.amazonservices.com/en_US/fba_inbound/FBAInbound_ListInboundShipmentItems.html
  # @param opts [Hash]
  # @option opts [String] :shipment_id
  # @option opts [String, #iso8601] :last_updated_after
  # @option opts [String, #iso8601] :last_updated_before
  # @return [Peddler::XMLParser]
  def list_inbound_shipment_items(opts = {})
    begin
      res = get_inbound_shipment_client.list_inbound_shipment_items(opts)
      Rails.logger.info res.data[:body]
      return res.data[:body]
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Returns PDF document data for printing package labels for an inbound
  # shipment
  #
  # @see http://docs.developer.amazonservices.com/en_US/fba_inbound/FBAInbound_GetPackageLabels.html
  # @param shipment_id [String]
  # @param page_type [String]
  # @param opts [Hash]
  # @option opts [Integer] :number_of_packages
  # @return [Peddler::XMLParser]
  def get_package_labels(shipment_id, page_type, opts = {})
    begin
      res = get_inbound_shipment_client.get_package_labels(shipment_id, page_type, opts)
      Rails.logger.info res.data[:body]
      info = Amazon::MWS::TransportDocument.parse(res.data[:body], :single => true, :use_default_namespace => true)
      return info
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
    # res = do_get_package_label(shipment_id, page_type, opts)
    # Rails.logger.info res
    # info = Amazon::MWS::TransportDocument.parse(res, :single => true, :use_default_namespace => true)
  end

  # Lists the marketplaces the seller participates in
  #
  # @see http://docs.developer.amazonservices.com/en_US/sellers/Sellers_ListMarketplaceParticipations.html
  # @param next_token [String]
  # @return [Peddler::XMLParser]
  def list_marketplace_participations
    begin
      res = get_sellers_client.list_marketplace_participations
      Rails.logger.info res.data[:body]

      return res.data[:body]
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Lists the next page of marketplaces the seller participates in
  #
  # @see http://docs.developer.amazonservices.com/en_US/sellers/Sellers_ListMarketplaceParticipationsByNextToken.html
  # @param next_token [String]
  # @return [Peddler::XMLParser]
  def list_marketplace_participations_by_next_token(next_token)
    begin
      res = get_sellers_client.list_marketplace_participations_by_next_token next_token
      Rails.logger.info res.data[:body]
      return res.data[:body]
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Lists orders
  #
  # @see http://docs.developer.amazonservices.com/en_US/orders/2013-09-01/Orders_ListOrders.html
  # @param opts [Hash]
  # @option opts [String, #iso8601] :created_after
  # @option opts [String, #iso8601] :created_before
  # @option opts [String, #iso8601] :last_updated_after
  # @option opts [String, #iso8601] :last_updated_before
  # @option opts [Array<String>, String] :order_status
  # @option opts [Array<String>, String] :marketplace_id
  # @option opts [Array<String>, String] :fulfillment_channel
  # @option opts [Array<String>, String] :payment_method
  # @option opts [String] :buyer_email
  # @option opts [String] :seller_order_id
  # @option opts [String] :max_results_per_page
  # @option opts [String] :tfm_shipment_status
  # @return [Peddler::XMLParser]
  # rubocop:disable MethodLength
  def list_orders(opts = {})
    begin
      res = get_order_client.list_orders(opts)
      Rails.logger.info res.data[:body]

      return res.data[:body]
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Lists the next page of orders
  #
  # @see http://docs.developer.amazonservices.com/en_US/orders/2013-09-01/Orders_ListOrdersByNextToken.html
  # @param next_token [String]
  # @return [Peddler::XMLParser]
  def list_orders_by_next_token(next_token)
    begin
      res = get_order_client.list_orders_by_next_token(next_token)
      Rails.logger.info res.data[:body]

      return res.data[:body]
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Gets one or more orders
  #
  # @see http://docs.developer.amazonservices.com/en_US/orders/2013-09-01/Orders_GetOrder.html
  # @param amazon_order_ids [Array<String>]
  # @return [Peddler::XMLParser]
  def get_order(*amazon_order_ids)
    begin
      res = get_order_client.get_order(*amazon_order_ids)
      Rails.logger.info res.data[:body]

      return res.data[:body]
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Lists order items for an order
  #
  # @see http://docs.developer.amazonservices.com/en_US/orders/2013-09-01/Orders_ListOrderItems.html
  # @param amazon_order_id [String]
  # @return [Peddler::XMLParser]
  def list_order_items(amazon_order_id)
    begin
      res = get_order_client.list_order_items(amazon_order_id)
      Rails.logger.info res.data[:body]

      return res.data[:body]
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  # Lists the next page of order items for an order
  #
  # @see http://docs.developer.amazonservices.com/en_US/orders/2013-09-01/Orders_ListOrderItemsByNextToken.html
  # @param next_token [String]
  # @return [Peddler::XMLParser]
  def list_order_items_by_next_token(next_token)
    begin
      res = get_order_client.list_order_items_by_next_token(next_token)
      Rails.logger.info res.data[:body]

      return res.data[:body]
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end


  # Gets the MWS Auth Token of the seller account
  #
  # @see http://docs.developer.amazonservices.com/en_US/auth_token/AuthToken_GetAuthToken.html
  # @return [Peddler::XMLParser]
  def get_auth_token
    begin
      res = get_sellers_client.get_auth_token
      Rails.logger.info res.data[:body]
      doc = REXML::Document.new(res.data[:body])

      return doc.elements['GetAuthTokenResponse/GetAuthTokenResult/MWSAuthToken'].text
    rescue => e
      if e.response.present?
        Rails.logger.error e.response.body
      end
      raise e
    end
  end

  private

  def get_product_client
    if @product_client.blank?
      @product_client = MWS.products(
          :marketplace_id => @marketplace_id,
          :merchant_id => @merchant_id,
          :aws_access_key_id => @access_key_id,
          :aws_secret_access_key => @secret_access_key
      )
      @product_client.auth_token = @auth_token if @auth_token.present?
    end
    @product_client
  end

  def get_feed_client
    if @feed_client.blank?
      @feed_client = MWS.feeds(
          :marketplace_id => @marketplace_id,
          :merchant_id => @merchant_id,
          :aws_access_key_id => @access_key_id,
          :aws_secret_access_key => @secret_access_key
      )
      @feed_client.auth_token = @auth_token if @auth_token.present?
    end
    @feed_client
  end

  def get_report_client
    if @report_client.blank?
      @report_client = MWS.reports(
          :marketplace_id => @marketplace_id,
          :merchant_id => @merchant_id,
          :aws_access_key_id => @access_key_id,
          :aws_secret_access_key => @secret_access_key
      )
      @report_client.auth_token = @auth_token if @auth_token.present?
    end
    @report_client
  end

  def get_order_client
    if @order_client.blank?
      @order_client = MWS.reports(
          :marketplace_id => @marketplace_id,
          :merchant_id => @merchant_id,
          :aws_access_key_id => @access_key_id,
          :aws_secret_access_key => @secret_access_key
      )
      @report_client.auth_token = @auth_token if @auth_token.present?
    end
    @order_client
  end

  def get_inbound_shipment_client
    if @inbound_shipment_client.blank?
      @inbound_shipment_client = MWS.fulfillment_inbound_shipment(
          :marketplace_id => @marketplace_id,
          :merchant_id => @merchant_id,
          :aws_access_key_id => @access_key_id,
          :aws_secret_access_key => @secret_access_key
      )
      @inbound_shipment_client.auth_token = @auth_token if @auth_token.present?
    end
    @inbound_shipment_client
  end

  def get_sellers_client
    if @sellers_client.blank?
      @sellers_client = MWS.sellers(
          :marketplace_id => @marketplace_id,
          :merchant_id => @merchant_id,
          :aws_access_key_id => @access_key_id,
          :aws_secret_access_key => @secret_access_key
      )
      @sellers_client.auth_token = @auth_token if @auth_token.present?
    end
    @sellers_client
  end

  def do_create_inbound_shipment_plan(address, items)
    @@ENDPOINT_SCHEME='https://'
    @@ENDPOINT_HOST='mws.amazonservices.jp' #Endpoint to JP MWS
    @@ENDPOINT_URI='/FulfillmentInboundShipment/2010-10-01'

    params={
        "AWSAccessKeyId" => @access_key_id,
        "MarketplaceId" => @marketplace_id,
        "SellerId" => @merchant_id,
        "SignatureMethod" => "HmacSHA256",
        "SignatureVersion" => "2",
        "Version" => "2010-10-01",
        "Timestamp" => Time.now.utc.iso8601
    }

    params["Action"]="CreateInboundShipmentPlan"
    params["MWSAuthToken "] = @auth_token if @auth_token.present?

    address.each do |key, value|
      params["ShipFromAddress.#{key}"] = value
    end

    items.each_with_index do |item, index|
      item.each do |key, value|
        params["InboundShipmentPlanRequestItems.member.#{index+1}.#{key}"] = value
      end
    end

    #Sorting parameters - パラメータのソート
    values = params.keys.sort.collect { |key| [URI.escape(key, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")), URI.escape(params[key].to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))].join("=") }
    param=values.join("&")

    #Creating Signature String - 電子署名の作成
    signtemp = "GET"+"\n"+@@ENDPOINT_HOST+"\n"+@@ENDPOINT_URI+"\n"+param
    signature_raw = Base64.encode64(OpenSSL::HMAC.digest('sha256', @secret_access_key, signtemp)).delete("\n")
    signature=URI.escape(signature_raw, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))

    param+="&Signature="+signature
    #Creating URL - URLの作成
    url=@@ENDPOINT_SCHEME+@@ENDPOINT_HOST+@@ENDPOINT_URI+"?"+param
    puts url


    uri=URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    #performing HTTP access - HTTPアクセスを実行
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    Rails.logger.info "#{response}, #{response.body}"
    #output results - 結果を出力
    response.body
  end

  def do_inbound_shipment(shipment_id, header, items, action)
    Rails.logger.info "action: #{action}, shipment_id: #{shipment_id}, header: #{header}, items: #{items}"

    @@ENDPOINT_SCHEME='https://'
    @@ENDPOINT_HOST='mws.amazonservices.jp' #Endpoint to JP MWS
    @@ENDPOINT_URI='/FulfillmentInboundShipment/2010-10-01'

    params={
        "AWSAccessKeyId" => @access_key_id,
        "MarketplaceId" => @marketplace_id,
        "SellerId" => @merchant_id,
        "SignatureMethod" => "HmacSHA256",
        "SignatureVersion" => "2",
        "Version" => "2010-10-01",
        "Timestamp" => Time.now.utc.iso8601
    }

    params["Action"]=action
    params["MWSAuthToken "] = @auth_token if @auth_token.present?

    params["ShipmentId"] = shipment_id

    header.each do |key, value|
      if value.instance_of?(Hash)
        value.each do |ckey, cvalue|
          params["InboundShipmentHeader.#{key}.#{ckey}"] = cvalue
        end
      else
        params["InboundShipmentHeader.#{key}"] = value
      end
    end

    items[:inbound_shipment_items].each_with_index do |item, index|
      item.each do |key, value|
        params["InboundShipmentItems.member.#{index+1}.#{key}"] = value
      end
    end

    #Sorting parameters - パラメータのソート
    values = params.keys.sort.collect { |key| [URI.escape(key, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")), URI.escape(params[key].to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))].join("=") }
    param=values.join("&")

    #Creating Signature String - 電子署名の作成
    signtemp = "GET"+"\n"+@@ENDPOINT_HOST+"\n"+@@ENDPOINT_URI+"\n"+param
    signature_raw = Base64.encode64(OpenSSL::HMAC.digest('sha256', @secret_access_key, signtemp)).delete("\n")
    signature=URI.escape(signature_raw, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))

    param+="&Signature="+signature
    #Creating URL - URLの作成
    url=@@ENDPOINT_SCHEME+@@ENDPOINT_HOST+@@ENDPOINT_URI+"?"+param
    puts url


    uri=URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    #performing HTTP access - HTTPアクセスを実行
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    Rails.logger.info "#{response}, #{response.body}"
    #output results - 結果を出力
    response.body
  end

  def do_get_package_label(shipment_id, page_type, opt)
    @@ENDPOINT_SCHEME='https://'
    @@ENDPOINT_HOST='mws.amazonservices.jp' #Endpoint to JP MWS
    @@ENDPOINT_URI='/FulfillmentInboundShipment/2010-10-01'

    params={
        "AWSAccessKeyId" => @access_key_id,
        "MarketplaceId" => @marketplace_id,
        "SellerId" => @merchant_id,
        "SignatureMethod" => "HmacSHA256",
        "SignatureVersion" => "2",
        "Version" => "2010-10-01",
        "Timestamp" => Time.now.utc.iso8601
    }

    params["Action"]="GetPackageLabels"
    params["MWSAuthToken "] = @auth_token if @auth_token.present?

    params["ShipmentId"] = shipment_id
    params["PageType"] = page_type
    params["NumberOfPackages"] = opt[:number_of_packages]

    #Sorting parameters - パラメータのソート
    values = params.keys.sort.collect { |key| [URI.escape(key, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")), URI.escape(params[key].to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))].join("=") }
    param=values.join("&")

    #Creating Signature String - 電子署名の作成
    signtemp = "GET"+"\n"+@@ENDPOINT_HOST+"\n"+@@ENDPOINT_URI+"\n"+param
    signature_raw = Base64.encode64(OpenSSL::HMAC.digest('sha256', @secret_access_key, signtemp)).delete("\n")
    signature=URI.escape(signature_raw, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))

    param+="&Signature="+signature
    #Creating URL - URLの作成
    url=@@ENDPOINT_SCHEME+@@ENDPOINT_HOST+@@ENDPOINT_URI+"?"+param
    puts url


    uri=URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    #performing HTTP access - HTTPアクセスを実行
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    Rails.logger.info "#{response}, #{response.body}"

    #output results - 結果を出力
    response.body
  end
end