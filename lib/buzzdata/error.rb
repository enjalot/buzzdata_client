class Buzzdata
  class Error < StandardError
    attr_reader :message

    def initialize(message='Error!')
      @message = message
    end
  end
end
