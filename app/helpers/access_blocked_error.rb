class AccessBlockedError < Mechanize::ResponseCodeError
  def initialize(page, message = nil)
    super(page, message = nil)
  end
end