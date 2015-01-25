# encoding: utf-8
require 'nkf'

module ScrapingHelper
  def extract_iscd(url)
    /([0-9].*)/ =~ url
    iscd = $1
  end
  def extract_number(txt)
    /([0-9]+)/ =~ txt
    number = $1
  end
  
  def extract_asin(url)
    /([B0-9][A-Z0-9]{9})/ =~ url
    iscd = $1
  end
  
  def extract_seller_id(url)
    /seller=(.*)/ =~ url
    seller_id = $1
  end
  
  def extract_seller_id_another(url)
    /shops\/([A-Z0-9]*)\/ref/ =~ url
    seller_id = $1
  end
  
  def extract_price(txt)
    /(\d{1,3}(,\d{3})*)/ =~ txt
    price = $1
    return 0 if price.blank?
    price.gsub(/,/,'').to_i
  end

  def extract_mixed_decimal_with_comma(txt)
    /([\d,]+(\.\d+)?)/ =~ txt
    decimal = $1
    return 0.0 if decimal.blank?
    decimal.gsub(/,/,'').to_f
  end

  def extract_mixed_decimala(txt)
    /(\d+(\.\d+)?)/ =~ txt
    decimal = $1
    return 0.0 if decimal.blank?
    decimal.gsub(/,/,'').to_f
  end
  
  def extract_count(txt)
    /([0-9].*)件/ =~ txt
    count = $1
  end
  
  def normalize(str)
    # -W1: 半カナ->全カナ, 全英->半英,全角スペース->半角スペース
    # -Ww: specify utf-8 as  input and output encodings
    NKF::nkf('-Z1 -Ww', str)
  end

  def extract_from_aucfan_url(url)
    /\/search\/aucview\/(.*)\/(.*)/ =~ url
    ret = {:auc_type => $1, :code => $2}
    ret
  end

  def extract_from_aucfan_auc_url(url)
    /\/search\/aucview\/(.*)\/(.*)/ =~ url
    ret = {:auc_type => $1, :code => $2}
    ret
  end

  def extract_camerafan_url(url)
    /location.href='(.*)'/ =~ url
    $1
  end

  def extract_code_from_camerafan_url(url)
    /i=(.*)$/ =~ url
    $1
  end

  def extract_code_from_jcamera_url(url)
    /id=(.*)$/ =~ url
    $1
  end

  def extract_date_by_format(txt)
    /([0-9]{4}\/[0-9]{1,2}\/[0-9]{1,2})/ =~ txt
    $1
  end

  def extract_code_from_kitamura_url(url)
    # /\/pd\/([0-9].*)\// =~ url
    /ac=([0-9].*)$/ =~ url
    $1
  end

  def extract_subcondition_from_kitamura(txt)
    /状態:([A-Z].*)/ =~ txt
    $1.chomp
  end

  def extract_code_from_ebay_url(url)
    # /\/pd\/([0-9].*)\// =~ url
    /\/([0-9].*)?pt=/ =~ url
    $1
  end
  
  def replace_invalid_utf(str)
    str.force_encoding('UTF-8')
    str = str.encode("UTF-16BE", "UTF-8", :invalid => :replace, :undef => :replace, :replace => '?').encode("UTF-8")
    str
  end
  
  def convert_date(date_str)
    return if date_str.blank?
    
    date_str =~ /(\d{4})年(\d{1,2})月(\d{1,2})日/
    date_str =~ /(\d{4})年(\d{1,2})月/ if $1.blank?
    date_str =~ /(\d{4})\/(\d{1,2})\/(\d{1,2})/ if $1.blank?
    date_str =~ /(\d{4})\/(\d{1,2})/ if $1.blank?
    year = $1
    month = sprintf("%02d", $2.to_i) 
    day = sprintf("%02d", $3.to_i) 
    
    Rails.logger.debug "#{date_str} => #{year} #{month} #{day}"
    
    begin
      if day.to_i > 0
        pubdate = DateTime.strptime("#{year}#{month}#{day}", '%Y%m%d')
      elsif month.to_i > 0
        pubdate = DateTime.strptime("#{year}#{month}", '%Y%m')
      end
    rescue => e
      Rails.logger.warn "#{e.message} src::#{date_str} => #{year} #{month} #{day}"
      pubdate = nil
    end
    pubdate
  end

end
