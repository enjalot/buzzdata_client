module RestHelpers

  def handle_error(response)
    raise Buzzdata::Error.new if response.nil?
    parsed_error = JSON.parse(response.body)
    raise Buzzdata::Error.new(parsed_error['message'])
  end

  # Define methods for our HTTP verbs
  [:post, :put, :get, :delete].each do |method|
    
    define_method(method) do |url, params={}|
      params['api_key'] = @api_key

      RestClient.send(method, url, params) do |response, request, result, &block|        
        case response.code
        when 403, 404, 500
          handle_error(response)
        else
          response.return!(request, result, &block)
        end
      end
    end

    # Define methods for our verbs with json handling
    define_method("#{method}_json") do |path, params={}|
      response = send(method, path, params)
      JSON.parse(response.body)
    end

  end
  
  def raw_get(url)
    RestClient.get(url)
  end

end
