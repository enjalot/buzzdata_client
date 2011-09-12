class Buzzdata
  class Upload

    attr_reader :filename, :size, :job_status_token, :dataset

    def initialize(buzzdata_api, dataset, upload_response)
      @api = buzzdata_api
      @dataset = dataset
      @filename = upload_response[0]['name']
      @size = upload_response[0]['size']
      @job_status_token = upload_response[0]['job_status_token']
    end

    def in_progress?
      !is_complete?(current_status)
    end

    def success?
      (current_status['status_code'] == "complete")
    end

    def status_message
      current_status['message']
    end

    private

      def is_complete?(status)
        return false if status.nil?        
        ['complete', 'error'].include?(status['status_code'])
      end

      def current_status
        return @current_status if is_complete?(@current_status)
        @current_status = @api.upload_status(@dataset, @job_status_token)
      end
  end
end