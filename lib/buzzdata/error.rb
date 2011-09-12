class Buzzdata
  class Error < Exception
    attr_reader :message

    def initialize(message='Error!')
      @message = message
    end
  end
end
