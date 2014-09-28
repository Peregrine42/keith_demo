class DecisionState

  def initialize **args
    @state = args
  end

  def respond_to? name
    @state.has_key? name || super
  end

  def method_missing name, *args
    return super unless respond_to? name
    return @state[name] if args.empty?
    super
  end

  def decision= arg
    @state[:decision] = arg
  end

  def next_state= arg
    @state[:next_state] = arg
  end

  def branch_state= arg
    @state[:branch_state] = arg
  end

  def possible_attributes
    [:next_state, :branch_state, :decision, :command, :message]
  end

  def next_state *args
    return branch_state if respond_to?(:decision) && decision.call(*args)
    @state[:next_state]
  end

  def result *args
    return @state[:result].call(*args) if @state[:result].respond_to?(:call)
    @state[:result]
  end
end
