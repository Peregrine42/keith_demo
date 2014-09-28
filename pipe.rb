require 'timeout'

class Pipe

  def initialize connection, timeout=10
    @connection = connection
    @timeout = timeout
  end

  def method_missing name, message
    begin
      Timeout::timeout(@timeout) do
        @connection.send name, message
      end
    rescue Timeout::Error
      raise Pipe::TimeoutError, message
    end
  end

end
