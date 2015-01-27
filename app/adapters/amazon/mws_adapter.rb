require 'peddler'

class Amazon::MwsAdapter
  attr_accessor :country
  def initialize(opt={})
    @country = "jp"
    @marketplace_id = opt[:marketplace_id]
    @merchant_id = opt[:merchant_id]
    @access_key_id = opt[:access_key_id]
    @secret_access_key = opt[:secret_access_key]

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
    get_product_client.list_matching_products(query, opts)
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
    get_product_client.get_matching_product_for_id(id_type, *id_list)
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
    get_product_client.get_matching_product(*asins)
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
    get_product_client.get_competitive_pricing_for_sku(*skus)
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
    get_product_client.get_competitive_pricing_for_asin(*asins)
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
    get_product_client.get_lowest_offer_listings_for_sku(*skus)
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
    get_product_client.get_lowest_offer_listings_for_asin(*asins)
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
    get_product_client.get_my_price_for_sku(*skus)
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
    get_product_client.get_my_price_for_asin(*asins)
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
    get_product_client.get_product_categories_for_sku(sku, opts)
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
    get_product_client.get_product_categories_for_asin(asin, opts)
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
    res = get_feed_client.submit_feed(feed_content, feed_type, opts)
    info = Amazon::MWS::Feed::SubmissionInfo.parse(
    res.data[:body], :single => true, :use_default_namespace => true)
    info
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
    res = get_feed_client.get_feed_submission_list(opts)
    res_list = Amazon::MWS::Feed::SubmissionList.parse(res.data[:body], :single => true, :use_default_namespace => true)
  end

  # Gets the processing report for a feed and its Content-MD5 header
  #
  # @see http://docs.developer.amazonservices.com/en_US/feeds/Feeds_GetFeedSubmissionResult.html
  # @param feed_submission_id [Integer, String]
  # @return [Peddler::XMLParser] if the report is in XML format
  # @return [Peddler::CSVParser] if the report is a flat file
  def get_feed_submission_result(feed_submission_id)
    get_feed_client.get_feed_submission_result(feed_submission_id)
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
    res = get_report_client.request_report(report_type, opts)
    info = Amazon::MWS::Report::ReportRequestInfo.parse(
    res.data[:body], :single => true, :use_default_namespace => true)
    info
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
    get_report_client.get_report_request_list(opts)
  end

  # Lists the next page of the report requests
  #
  # @see http://docs.developer.amazonservices.com/en_US/reports/Reports_GetReportRequestListByNextToken.html
  # @param next_token [String]
  # @return [Peddler::XMLParser]
  def get_report_request_list_by_next_token(next_token)
    get_report_client.get_report_request_list_by_next_token next_token
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
    get_report_client.get_report_request_count opts
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
    get_report_client.cancel_report_requests opts
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
    get_report_client.get_report_list opts
  end

  # Lists the next page of reports
  #
  # @see http://docs.developer.amazonservices.com/en_US/reports/Reports_GetReportListByNextToken.html
  # @param next_token [String]
  # @return [Peddler::XMLParser]
  def get_report_list_by_next_token(next_token)
    get_report_client.get_report_list_by_next_token next_token
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
    get_report_client.get_report_count opts
  end

  # Gets a report and its Content-MD5 header
  #
  # @see http://docs.developer.amazonservices.com/en_US/reports/Reports_GetReport.html
  # @param report_id [String]
  # @return [Peddler::XMLParser] if report is in XML format
  # @return [Peddler::CSVParser] if report is a flat file
  def get_report(report_id, &blk)
    get_report_client.get_report(report_id)

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
    get_report_client.manage_report_schedule(report_type, schedule, opts)
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
    get_report_client.get_report_schedule_list_by_next_token next_token
  end

  # Count scheduled reports
  #
  # @see http://docs.developer.amazonservices.com/en_US/reports/Reports_GetReportScheduleCount.html
  # @param report_type_list [Array<String>]
  # @return [Peddler::XMLParser]
  def get_report_schedule_count(*report_type_list)
    get_report_client.get_report_schedule_count report_type_list
  end

  # Update acknowledged status of one or more reports
  #
  # @see http://docs.developer.amazonservices.com/en_US/reports/Reports_UpdateReportAcknowledgements.html
  # @param acknowledged [Boolean]
  # @param report_id_list [Array<String>]
  # @return [Peddler::XMLParser]
  def update_report_acknowledgements(acknowledged, *report_id_list)
    get_report_client.update_report_acknowledgements(acknowledged, report_id_list)
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
    res = get_inbound_shipment_client.create_inbound_shipment_plan(ship_from_address, inbound_shipment_plan_request_items, opts)
    info = Amazon::MWS::FullfillmentInbound::ShipmentPlanList.parse(res.data[:body], :single => true, :use_default_namespace => true)
    plans = []
    info.plans.each{|plan| plans << plan if plan.shipment_id.present?}
    plans
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
    res = get_inbound_shipment_client.create_inbound_shipment(shipment_id, inbound_shipment_header, opts)
    Rails.logger.info res.data[:body]
    info = Amazon::MWS::FullfillmentInbound::CreateShipmentResult.parse(res.data[:body], :single => true, :use_default_namespace => true)
    Rails.logger.debug info.inspect
    info
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
    res = get_inbound_shipment_client.update_inbound_shipment(shipment_id, inbound_shipment_header, opts)
    Rails.logger.info res.data[:body]
    info = Amazon::MWS::FullfillmentInbound::UpdateShipmentResult.parse(res.data[:body], :single => true, :use_default_namespace => true)
    Rails.logger.debug info.inspect
    info
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
    res = get_inbound_shipment_client.list_inbound_shipments(opts)
    Rails.logger.info res.data[:body]
    res.data[:body]
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
    res = get_inbound_shipment_client.list_inbound_shipment_items(opts)
    Rails.logger.info res.data[:body]
    res.data[:body]
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
    res = get_inbound_shipment_client.get_package_labels(shipment_id, page_type, opts)
    Rails.logger.info res.data[:body]
    info = Amazon::MWS::TransportDocument.parse(res.data[:body], :single => true, :use_default_namespace => true)
  end

  # Lists the marketplaces the seller participates in
  #
  # @see http://docs.developer.amazonservices.com/en_US/sellers/Sellers_ListMarketplaceParticipations.html
  # @param next_token [String]
  # @return [Peddler::XMLParser]
  def list_marketplace_participations
    res = get_sellers_client.list_marketplace_participations
    Rails.logger.info res.data[:body]
    res.data[:body]
  end

  # Lists the next page of marketplaces the seller participates in
  #
  # @see http://docs.developer.amazonservices.com/en_US/sellers/Sellers_ListMarketplaceParticipationsByNextToken.html
  # @param next_token [String]
  # @return [Peddler::XMLParser]
  def list_marketplace_participations_by_next_token(next_token)
    res = get_sellers_client.list_marketplace_participations_by_next_token next_token
    Rails.logger.info res.data[:body]
    res.data[:body]
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
    end
    @report_client
  end

  def get_inbound_shipment_client
    if @inbound_shipment_client.blank?
      @inbound_shipment_client = MWS.fulfillment_inbound_shipment(
        :marketplace_id => @marketplace_id,
        :merchant_id => @merchant_id,
        :aws_access_key_id => @access_key_id,
        :aws_secret_access_key => @secret_access_key
      )
      puts @inbound_shipment_client.inspect
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
      puts @sellers_client.inspect
    end
    @sellers_client
  end

end