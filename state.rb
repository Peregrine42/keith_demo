class State

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

  def next_step= arg
    @state[:next_step] = arg
  end

  def branch_step= arg
    @state[:branch_step] = arg
  end

  def possible_attributes
    [:next_step, :branch_step, :decision, :command, :message]
  end

  def next_step *args
    return branch_step if respond_to?(:decision) && decision.call(*args)
    @state[:next_step]
  end

  def result *args
    return @state[:result].call(*args) if @state[:result].respond_to?(:call)
    @state[:result]
  end
end
