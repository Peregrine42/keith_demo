class Keith

  def initialize state, pipe=nil
    @state = state
    @pipe  = pipe
  end

  def walk results=nil
    results << @state.name if results
    pipe_response = @pipe.puts @state.name if @pipe
    if @state.next
      continue_walking pipe_response, results
    end
    results
  end

  private
  def continue_walking pipe_response, results
    if @state.next.respond_to? :[]
      new_state = @state.next[pipe_response]
    else
      new_state = @state.next
    end
    return Keith.new(new_state, @pipe).walk(results)
  end

end
