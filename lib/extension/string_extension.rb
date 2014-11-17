class String
  def sjisable
    str = self
    # str = str.exchange("U+301C", "U+FF5E") # wave-dash
    str = str.exchange("U+FF5E", "U+301C") # wave-dash
    str = str.exchange("U+2212", "U+FF0D") # full-width minus
    str = str.exchange("U+00A2", "U+FFE0") # cent as currency
    str = str.exchange("U+00A3", "U+FFE1") # lb(pound) as currency
    str = str.exchange("U+00AC", "U+FFE2") # not in boolean algebra
    str = str.exchange("U+2014", "U+2015") # hyphen
    str = str.exchange("U+2016", "U+2225") # double vertical lines
  end

  def exchange(before_str,after_str)
    self.gsub( before_str.to_code.chr('UTF-8'),
    after_str.to_code.chr('UTF-8') )
  end

  def to_code
    return $1.to_i(16) if self =~ /U\+(\w+)/
    raise ArgumentError, "Invalid argument: #{self}"
  end

  def sjis_safe
    [
      ["301C", "FF5E"], # wave-dash
      ["2212", "FF0D"], # full-width minus
      ["00A2", "FFE0"], # cent as currency
      ["00A3", "FFE1"], # lb(pound) as currency
      ["00AC", "FFE2"], # not in boolean algebra
      ["2014", "2015"], # hyphen
      ["2016", "2225"], # double vertical lines
    ].inject(self) do |s, (before, after)|
      s.gsub(
      after.to_i(16).chr('UTF-8'),
      before.to_i(16).chr('UTF-8')
      )
    end
  end

  def get_text_as_html
    html = self.gsub(/\r\n|\r|\n/, "<br />")
    
    URI.extract(html, %w{http https}).uniq.each do |uri|
      unless uri.match(/(\.jpg|\.jpeg|\.png)/)
        html.gsub!(uri, %Q{<a href="#{uri}" target="_blank"">#{uri}</a>})
      end
    end
    html
  end  

end
