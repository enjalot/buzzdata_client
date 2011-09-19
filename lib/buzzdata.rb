# Dependencies
require 'rest-client'
require 'json'
require 'yaml'

# Our code
require_relative 'buzzdata/error'
require_relative 'buzzdata/rest_helpers'
require_relative 'buzzdata/upload'

class Buzzdata
  YAML_ERRORS = [ArgumentError]
  if defined?(Psych) && defined?(Psych::SyntaxError)
    YAML_ERRORS << Psych::SyntaxError
  end

  include RestHelpers
  
  def initialize(api_key=nil, opts={})
    
    @api_key = api_key
    
    # If the API Key is missing, try to load it from a yml
    if @api_key.nil?
      config_file = File.expand_path(opts[:config_file] || 'config/buzzdata.yml')

      # If the user set the config file, we want to raise errors.
      if opts[:config_file] || File.exist?(config_file)
        begin
          config = YAML.load_file config_file
          if Hash === config
            if config['api_key']
              @api_key = config['api_key']
              @base_url = config['base_url']
            else
              raise Buzzdata::Error, "API key missing from configuration file (#{config_file})"
            end
          else
            raise Buzzdata::Error, "Configuration file improperly formatted (not a Hash: #{config_file})"
          end
        rescue *YAML_ERRORS
          raise Buzzdata::Error, "Configuration file improperly formatted (invalid YAML: #{config_file})"
        rescue Errno::EACCES
          raise Buzzdata::Error, "Configuration file unreadable (Permission denied: #{config_file})"
        rescue Errno::ENOENT
          raise Buzzdata::Error, "Configuration file missing (No such file or directory: #{config_file})"
        end
      end

      raise Buzzdata::Error.new('No API key provided') if @api_key.nil?
    end
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
  
  def dataset_overview(dataset)
    result = get_json(url_for(dataset))
    result['dataset']
  end

  def publish_dataset(dataset)
    result = post_json(url_for("#{dataset}/publish"))
    result['dataset']
  end

  def clone_dataset(dataset)
    result = post_json(url_for("#{dataset}/clone"))
    result['dataset']
  end

  def delete_dataset(dataset)
    delete_json(url_for("#{dataset}"))
  end

  def licenses
    get_json(url_for("licenses"))
  end

  def topics
    get_json(url_for("topics"))
  end

  def download_data(dataset)
    raw_get(download_path(dataset))
  end

  def create_dataset(attributes)
    
    # Validate attributes
    raise BuzzData::Error, "Missing attributes" if attributes.nil?    
    raise Buzzdata::Error, "Username is required" if param_blank?(attributes, :username)
    raise Buzzdata::Error, "Dataset name is required" if param_blank?(attributes, :name)
    raise Buzzdata::Error, "Dataset readme is required" if param_blank?(attributes, :name)
    raise Buzzdata::Error, "Dataset license is required" if param_blank?(attributes, :license)
    raise Buzzdata::Error, "Dataset topics are required" if param_blank?(attributes, :topics)

    username = attributes.delete(:username)

    result = post_json(url_for("#{username}/datasets"), :dataset => attributes)    
    result['dataset']
  end

  private
    
    def param_blank?(obj, param)      
      return (obj.nil? or obj[param].nil? or obj[param].empty?)
    end

    def url_for(path)
      base_path = @base_url || "https://buzzdata.com/api/"
      "#{base_path}#{path}"
    end
  
end


