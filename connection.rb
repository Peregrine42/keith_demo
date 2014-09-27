class Connection

  def initialize connection, prompt=nil
    @connection = connection
    @prompt = prompt
  end

  def puts message
    @connection.puts message
  end

  def puts_and_wait_for_prompt message, prompt=nil
    prompt ||= @prompt
    raise Connection::Error, 'no prompt given' if prompt.nil?
    @connection.puts message
    @connection.waitfor prompt
  end
end

class Connection::Error < StandardError
end
