class Hash
  def method_missing(method, *params)
    method_string = method.to_s
    if method_string.last == "="
      self[method_string[0..-2]] = params.first
    else
      self[method_string] 
    end
  end
  
  def merge_flat(model)
    self.each do |key, value|
      method = "#{key}="
      next unless model.respond_to? method
      
      data = value
      if Hash.try_convert(value).present?
        data = value.to_json
      end
      model.send(method, data) 
    end
    model
  end
end