# Dependencies
require 'rest-client'
require 'json'
require 'yaml'

# Our code
require_relative 'buzzdata/error'
require_relative 'buzzdata/rest_helpers'
require_relative 'buzzdata/upload'

class Buzzdata
  include RestHelpers
  
  def initialize(api_key=nil, opts={})
    
    @api_key = api_key
    
    config_file = opts[:config_file] || "config/buzzdata.yml"
    
    # If the API Key is missing, try to load it from a yml
    if File.exist?("config/buzzdata.yml")
      config = YAML.load_file("config/buzzdata.yml")
      
      if config
        @api_key ||= config['api_key'] 
        @base_url = config['base_url']
      end
    end
    
    raise Buzzdata::Error.new('No API Key Provided') if @api_key.nil?
  end

  def new_upload_request(dataset)
    result = post_json(url_for("#{dataset}/upload_request"))
    result['upload_request']
  end

  def start_upload(dataset, file)
    upload_request = new_upload_request(dataset)

    # Prepare our request
    post_url = upload_request.delete('url')
    upload_request['file'] = file
    
    Buzzdata::Upload.new(self, dataset, post_json(post_url, upload_request))    
  end 

  def upload_status(dataset, job_status_token)
    get_json(url_for("#{dataset}/upload_request/status"), :job_status_token => job_status_token)
  end

  def download_path(dataset)
    result = post_json(url_for("#{dataset}/download_request"))
    result['download_request']['url']
  end
  
  def download_data(dataset)
    raw_get(download_path(dataset))
  end

  private
    
    def url_for(path)
      base_path = @base_url || "https://buzzdata.com/api/"
      "#{base_path}#{path}"
    end
  
end


