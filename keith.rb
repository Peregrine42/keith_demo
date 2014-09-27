class Keith

  attr_accessor :state

  def initialize pipe, command=:puts_and_wait_for_prompt
    @pipe  = pipe
    @default_command = command
  end

  def walk result = :no_result, pipe_response = :no_response
    command = @default_command
    command = @state.command if @state.respond_to? :command

    pipe_response = @pipe.send command, @state.message if @state.respond_to? :message

    current_result = @state.result(result, pipe_response) if @state.respond_to? :result
    if @state.respond_to? :next_state
      @state = @state.next_state pipe_response
      walk current_result, pipe_response
    else
      current_result
    end
  end

end
