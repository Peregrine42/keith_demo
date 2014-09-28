require 'timeout'

class Pipe

  def initialize connection, timeout=10
    @connection = connection
    @timeout = timeout
  end

  def puts message
    send_with_timeout :puts, message
  end

  def puts_and_wait_for_prompt message
    send_with_timeout :puts_and_wait_for_prompt, message
  end

  def send_with_timeout name, message
    begin
      Timeout::timeout(@timeout) do
        @connection.send name, message
      end
    rescue Timeout::Error
      raise Pipe::TimeoutError, message
    end
  end

end
