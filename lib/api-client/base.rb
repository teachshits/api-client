require "active_model"

class ApiClient::Base
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  extend ApiClient::Parser
  extend ApiClient::Dispatcher

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def self.get(url = '')
    dispatch { _get(url) }
  end

  def self.post(url = '', args = {})
    dispatch { _post(url, args) }
  end

  protected

  def self.dispatch
    begin
      code, body = _response(yield)
    rescue Errno::ECONNREFUSED
      raise ApiClient::Exceptions::ConnectionRefused
    end
    raise_exception(code)
    new(body)
  end

  def self.raise_exception(code)
    case code
      when '401' then raise ApiClient::Exceptions::Unauthorized
      when '403' then raise ApiClient::Exceptions::Forbidden
      when '404' then raise ApiClient::Exceptions::NotFound
      when '500' then raise ApiClient::Exceptions::InternalServerError
      when '502' then raise ApiClient::Exceptions::BadGateway
      when '503' then raise ApiClient::Exceptions::ServiceUnavailable
      else return
    end
  end
end