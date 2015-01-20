# encoding: utf-8
require "aws-sdk"
# require "aws_ec2_config"

class Amazon::SesAdapter < Amazon::AwsAdapter

  def verify_email_identity(email_address)
    Rails.logger.debug "do verify_email_identity params=#{email_address}"
    create_client.verify_email_identity({email_address: email_address})
  end
  
  def delete_identity(email_address)
    Rails.logger.debug "do delete_identity params=#{email_address}"
    create_client.delete_identity({identity: email_address})
  end
  
  def list_verified_email_addresses
    Rails.logger.debug "do list_verified_email_addresses"
    response = create_client.list_verified_email_addresses
    list = response[:verified_email_addresses]
    list
  end

  def list_identities_to_email(opts={})
    opts[:identity_type] = "EmailAddress"
    ret = self.list_identities opts
    ret
  end

  def list_identities_to_domain(opts={})
    opts[:identity_type] = "Domain"
    ret = self.list_identities opts
    ret
  end

  def list_identities(opts={})
    Rails.logger.debug "do list_identities params=#{opts}"
    response = create_client.list_identities opts
    ret = {
      identities: response[:identities],
      next_token: response[:next_token]
    }
    ret
  end
  
  def set_identity_dkim_enabled(indentity, enable)
    Rails.logger.debug "do set_identity_dkim_enabled params=#{indentity}, #{enable}"
    opts = {identity: indentity, dkim_enabled: enable}
    create_client.set_identity_dkim_enabled opts
  end

  def get_identity_dkim_attributes(*indentity)
    Rails.logger.debug "do get_identity_dkim_attributes params=#{indentity}"
    opts = {identities: indentity}
    response = create_client.get_identity_dkim_attributes opts
    response[:dkim_attributes]
  end

  def get_identity_verification_attributes(*indentity)
    Rails.logger.debug "do get_identity_verification_attributes params=#{indentity}"
    opts = {identities: indentity}
    response = create_client.get_identity_verification_attributes opts
    response[:verification_attributes]
  end
  
  def verified_email?(email)
    res = self.get_identity_verification_attributes email
    
    ret = false
    if res.present? && res[email].present?
      Rails.logger.debug "#{res[email]}"
      if res[email][:verification_status] == "Success"
        ret = true
      end
    end
    Rails.logger.info "verified_email? #{email} = #{ret}"
    ret
  end
  
  def verified_dkim?(identity)
    res = self.get_identity_dkim_attributes identity
    
    ret = false
    if res.present? && res[identity].present?
      Rails.logger.debug "#{res[identity]}"
      if res[identity][:dkim_enabled] && res[identity][:dkim_verification_status] == "Success"
        ret = true
      end
    end
    Rails.logger.info "verified_dkim? #{identity} = #{ret}"
    ret
  end

  private
  def create_client
    client = AWS::SimpleEmailService::Client.new
    client
  end
end