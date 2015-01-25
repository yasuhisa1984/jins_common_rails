# encoding: utf-8
require 'mechanize'
require 'nkf'

module HttpRequestHelper
  @RETRY_LIMIT=3
  
  def create_http_agent
    agent = Mechanize.new# {|a| a.log=Logger.new(STDOUT)}
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

    agent.request_headers = {
      'accept-language' => 'ja, ja-JP, en',
      'accept-encoding' => 'utf-8, us-ascii'
    }
    return agent
  end
  
  def do_request(agent, method, *opt)
    retry_count = 0
    is_success = false
    begin
      page = agent.send(method, *opt)
      is_success = true
    rescue Timeout::Error => te
      Rails.logger.warn "Timeout::Error! => #{url}"
      if retry_count < @RETRY_LIMIT
        retry_count += 1
        retry 
      else
        raise te
      end
    rescue WWW::Mechanize::ResponseCodeError => e
      case e.response_code
      when "404"
        Rails.logger.warn "  caught Net::HTTPNotFound ! skip this url: #{url}"
        return is_success
      when "403"
        Rails.logger.warn "  caught Net::HTTPForbidone ! ->retry? count:#{retry_count} ,url: #{url}"
        sleep 180 # wait 3 minutes.
      when "502"
        Rails.logger.warn "  caught Net::HTTPBadGateway ! ->retry? count:#{retry_count} ,url: #{url}"
      else
        Rails.logger.warn "  caught Excepcion ! statue:#{e.response_code} ->retry? count:#{retry_count} ,url: #{url}"
      end
      if retry_count < @RETRY_LIMIT
        retry_count += 1
        retry 
      else
        raise e
      end
    end
    is_success
  end

  def output_page(filepath, agent)
    agent.page.save(filepath)
  end

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
