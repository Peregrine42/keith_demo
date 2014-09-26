class Keith

  def initialize state, pipe=nil
    @state = state
    @pipe  = pipe
  end

  def walk
    pipe_response = @pipe.puts @state.name if @pipe
    result = @state.result(result, pipe_response) if @state.respond_to? :result
    if @state.next
      decide_next_state pipe_response
    else
      result
    end
  end

  private
  def decide_next_state pipe_response
    if @state.next.respond_to? :[]
      new_state = @state.next.map do |key, value|
        key.match(pipe_response) ? value : nil
      end.reject { |item| item.nil? }.first
    else
      new_state = @state.next
    end
    return Keith.new(new_state, @pipe).walk
  end

end
