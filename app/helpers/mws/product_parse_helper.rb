module Mws::ProductParseHelper
  
  def parse_lowest_offer(res)
    lowest_offer_doc = Nokogiri::XML(res.data[:body])
    lowest_offer_doc.remove_namespaces!

    offers = []
    lowest_offer_doc.xpath('//GetLowestOfferListingsForASINResult').each do |result|
      asin = result.attribute('ASIN').value
      market_place_id = result.xpath('.//MarketplaceId').text
      all_considered = result.xpath('./AllOfferListingsConsidered').text
      
      result_data = {
        "New" => [],
        "Used" => [],
        "Collectible" => [],
        "Refurbished" => [],
      }
      result.xpath('.//LowestOfferListing').each do |listing|
        listing_data = extract_listing listing
        Rails.logger.info "offer condition is #{listing_data[:condition]}"
        result_data[listing_data[:condition]] << listing_data unless result_data[listing_data[:condition]].nil?
      end
      
      offer_count = {
        "New" => 0,
        "Used" => 0,
        "Collectible" => 0,
        "Refurbished" => 0,
      }
      
      result_data.each do |condition, listings|
        sorted = listings.sort{|a, b| a[:landed_price] <=> b[:landed_price]}
        result_data[condition] = sorted
        
        sorted.each do |listing|
          offer_count[condition] += listing[:offers]
        end
      end
      
      search_time = Time.now
      
      offer = {
        :asin => asin,
        :market_place_id => market_place_id,
        :target_date => search_time.strftime("%Y%m%d"),
        :search_time => search_time,
        :new_offers => offer_count["New"],
        :used_offers => offer_count["Used"],
        :collectible_offers => offer_count["Collectible"],
        :refurbished_offers => offer_count["Refurbished"],
        :new_data => result_data["New"].present? ? result_data["New"].to_json : nil,
        :used_data => result_data["Used"].present? ? result_data["Used"].to_json : nil,
        :collectible_data => result_data["Collectible"].present? ? result_data["Collectible"].to_json : nil,
        :refurbished_data => result_data["Refurbished"].present? ? result_data["Refurbished"].to_json : nil,
      }
      
      [
        {:condition => "New", :method => [:new_lowest=, :new_shipping=, :new_fba_lowest=]},
        {:condition => "Used", :method => [:used_lowest=, :used_shipping=, :used_fba_lowest=]},
        {:condition => "Collectible", :method => [:collectible_lowest=, :collectible_shipping=, :collectible_fba_lowest=]},
        {:condition => "Refurbished", :method => [:refurbished_lowest=, :refurbished_shipping=, :refurbished_fba_lowest=]}
      ].each do |defs|
        if result_data[defs[:condition]].present?
          condition = defs[:condition]
          methods = defs[:method]
          offer.send(methods.first, result_data[condition].first[:listing_price])
          offer.send(methods[1], result_data[condition].first[:shipping])
          result_data[condition].each do |listing|
            offer.send(methods.last, listing[:listing_price]) if listing[:channel] == "Amazon"
          end
        end
      end
      
      Rails.logger.debug offer
      offers << offer
    end
    offers
  end

  def parse_competitive_pricing(res)
    competitive_pricing_doc = Nokogiri::XML(res.data[:body])
    competitive_pricing_doc.remove_namespaces!
    
    Rails.logger.debug competitive_pricing_doc.to_xml
    offers = []
    competitive_pricing_doc.xpath('//Product').each do |product|
      offer = {}
      offer[:market_place_id]= product.xpath('.//MarketplaceASIN/MarketplaceId').first.text
      offer[:asin] = product.xpath('.//MarketplaceASIN/ASIN').first.text
      
      listing_count = {}
      product.xpath('.//NumberOfOfferListings/OfferListingCount').each do |listings|
        condition = listings.attribute('condition').value
        
        key = nil
        case condition
        when "New"
         key = :new_offers
        when "Used"
         key = :used_offers
        when "Collectible"
         key = :collectible_offers
        when "Refurbished"
         key = :refurbished_offers
        end
        
        offer[key] = listings.text.to_i if key.present?
        # listing_count[listings.attribute('condition').value] = listings.text.to_i
      end
      # offer[:listing_count] = listing_count
      
      rank_tags = product.xpath('.//SalesRank')
      
      if rank_tags.present?
        sales_ranks = []
        rank_tags.each do |sales_rank|
          sales_ranks << {id: sales_rank.xpath('./ProductCategoryId').text, rank: sales_rank.xpath('./Rank').text.to_i}
        end
        offer[:sales_rank] = sales_ranks.first[:rank]
        offer[:sales_ranks] = sales_ranks
      end
      
      pricing_tags = product.xpath('.//CompetitivePrice')
      
      if pricing_tags.present?
        pricing_tags.each do |pricing|
          price_id = pricing.xpath('.//CompetitivePriceId').text
          listing_price = pricing.xpath('.//ListingPrice/Amount').text.to_f
          shipping = pricing.xpath('.//Shipping/Amount').text.to_f
          Rails.logger.info "CompetitivePriceId:#{price_id}, price:#{listing_price}, shipping:#{shipping}"
          
          case price_id
          when "1"
            Rails.logger.info "CompetitivePriceId:1, price:#{listing_price}, shipping:#{shipping}"
            offer[:new_cart_price] = listing_price
            offer[:new_cart_shipping] = shipping
          when "2"
            Rails.logger.info "CompetitivePriceId:2"
            offer[:used_cart_price] = listing_price
            offer[:used_cart_shipping] = shipping
          end
        end
      end
      
      Rails.logger.debug offer
      offers << offer
    end
    offers
  end
 
  def extract_listing(listing)
    qualify = listing.xpath('./Qualifiers').first
    offers = listing.xpath('./NumberOfOfferListingsConsidered').first.text.to_i
    feedbacks = listing.xpath('./SellerFeedbackCount').first.text.to_i
    is_multiple = listing.xpath('./MultipleOffersAtLowestPrice').first.text
    price = listing.xpath('./Price').first
    currency_code = price.xpath('./LandedPrice/CurrencyCode').text
    
    listing = {
      :condition => qualify.xpath('./ItemCondition').first.text,
      :sub_condition => qualify.xpath('./ItemSubcondition').first.text,
      :channel => qualify.xpath('./FulfillmentChannel').first.text,
      :to_domestics => qualify.xpath('./ShipsDomestically').first.text,
      :shiping_time_max => qualify.xpath('./ShippingTime/Max').first.text,
      :seller_feedback_rate => qualify.xpath('./SellerPositiveFeedbackRating').first.text,
      :offers => offers,
      :feedbacks => feedbacks,
      :currency => currency_code,
      :landed_price => price.xpath('./LandedPrice/Amount').first.text.to_f,
      :listing_price => price.xpath('./ListingPrice/Amount').first.text.to_f,
      :shipping => price.xpath('./Shipping/Amount').first.text.to_f,
      :is_multiple => is_multiple,
    }
  end
end