module Encrypt
  def encryptor
    secret = EncryptConf.secret
    ::ActiveSupport::MessageEncryptor.new(secret)
  end
end
