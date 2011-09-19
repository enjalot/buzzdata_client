module RestHelpers

  def handle_error(response)
    raise Buzzdata::Error.new if response.nil?
    parsed_error = JSON.parse(response.body)
    raise Buzzdata::Error.new(parsed_error['message'])
  end

  def post(url, params={})
    params['api_key'] = @api_key
    RestClient.post(url, params) do |response, request, result, &block|
      case response.code
      when 403, 404, 500
        handle_error(response)
      else
        response.return!(request, result, &block)
      end
    end
  end
    
  def get(url, params={})
    params['api_key'] = @api_key
    RestClient.get(url, :params => params) do |response, request, result, &block|
      case response.code
      when 403, 404, 500
        handle_error(response)
      else
        response.return!(request, result, &block)
      end
    end
  end

  def delete(url, params={})
    params['api_key'] = @api_key
    RestClient.delete(url, :params => params) do |response, request, result, &block|
      case response.code
      when 403, 404, 500
        handle_error(response)
      else
        response.return!(request, result, &block)
      end
    end
  end

  def get_json(path, params={})
    response = get(path, params)    
    JSON.parse(response.body)
  end

  def post_json(path, params={})
    response = post(path, params)    
    json = JSON.parse(response.body)
  end

  def delete_json(path, params={})
    response = delete(path, params)    
    json = JSON.parse(response.body)
  end
  
  def raw_get(url)
    RestClient.get(url)
  end
end
