require 'mechanize'
require 'nkf'

class Common::ScrapingAdapter
  
  def initialize
    @req_cache = {}
  end

  def create_http_agent
    agent = Mechanize.new
    # User-AgentをMac Safariに指定
    agent.user_agent_alias = ['Mac FireFox','Mac Safari','Windows IE 7'].sample
    # HTTPS対策：証明書を検証しない
    agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
    # 日本語エンコーディング対策
    agent.post_connect_hooks << fix_charset_to_utf8
    # タイムアウト対応
    agent.idle_timeout = 0.5
    agent.read_timeout = 100 # 100sec timeout
    agent.keep_alive = true
    agent.ignore_bad_chunking = true
    return agent
  end
  
  def put_agent_cache(key, agent)
    @req_cache[key] = agent
  end
  
  def get_agent_cache(key, agent)
    if @req_cache[key].blank?
      agent = create_http_agent
      @req_cache[key] = agent
    end
    @req_cache[key]
  end

  def extract_iscd(url)
    /([0-9].*)/ =~ url
    iscd = $1
  end
  
  def extract_price(txt)
    /(\d{1,3}(,\d{3})*)/ =~ txt
    price = $1
    return 0 if price.blank?
    price.gsub(/,/,'').to_i
  end
  
  def normalize(str)
    # -W1: 半カナ->全カナ, 全英->半英,全角スペース->半角スペース
    # -Ww: specify utf-8 as  input and output encodings
    NKF::nkf('-Z1 -Ww', str)
  end  
  private 
  
  def fix_charset_to_utf8(more_nkf_options = "")
    lambda do |a, uri, response, res_body|
      if content_type = response["Content-Type"]
        content_type.sub!(/charset\s*=\s*([^;\s]+)/i, "charset=UTF-8")
        response["Content-Type"] = content_type
      end

      encoded_res_body = NKF.nkf("-w -m0 #{more_nkf_options}", res_body)
      if m = encoded_res_body.match(/<\?xml[^>]+encoding\s*=\s*["']([^>\s]+)["'][^>]*\?>/i)
        encoded_res_body[Range.new(m.begin(1), m.end(1) - 1)] = "UTF-8"
      end
      if m = encoded_res_body.match(/<meta[^>]+charset\s*=\s*([^>"'\/\s]+)[^>]*>/i)
        encoded_res_body[Range.new(m.begin(1), m.end(1) - 1)] = "UTF-8"
      end
      res_body = encoded_res_body
    end
  end
end