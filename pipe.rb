require 'timeout'

class Pipe

  def initialize connection, timeout=10
    @connection = connection
    @timeout = timeout
  end

  def puts message
    begin
      Timeout::timeout(@timeout) do
        @connection.puts message
      end
    rescue Timeout::Error
      raise Pipe::TimeoutError, message
    end
  end

end
