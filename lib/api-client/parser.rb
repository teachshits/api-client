require 'json'

# ApiClient::Parser provides a method to parse the request response.
module ApiClient::Parser
  # Parse the JSON response.
  #
  # @param [HTTP] response HTTP object for the request.
  # @param [String] url The url of the requisition.
  # @return [Hash] the body parsed.
  def self.response(response, url)
    raise_exception(response, url)
    begin
      object = ::JSON.parse(response.body)
    rescue ::JSON::ParserError, TypeError
      object = {}
    end
    object
  end

  protected

  def self.raise_exception(response, url)
    case response.code.to_i
      when 401 then raise ApiClient::Exceptions::Unauthorized
      when 403 then raise ApiClient::Exceptions::Forbidden
      when 404 then raise ApiClient::Exceptions::NotFound.new(url)
      when 500 then raise ApiClient::Exceptions::InternalServerError
      when 502 then raise ApiClient::Exceptions::BadGateway
      when 503 then raise ApiClient::Exceptions::ServiceUnavailable
      else return
    end
  end
end