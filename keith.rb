class Keith

  attr_accessor :state

  def initialize pipe, command=:puts
    @pipe  = pipe
    @default_command = command
  end

  def walk result = [], pipe_response = :no_response
    command = @default_command
    command = @state.command if @state.respond_to? :command

    pipe_response = @pipe.send command, @state.message if @state.respond_to? :message

    result << @state.result(pipe_response) if @state.respond_to? :result
    if @state.respond_to? :next_state
      @state = @state.next_state pipe_response
      walk result, pipe_response
    else
      result
    end
  end

end
