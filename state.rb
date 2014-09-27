require 'hashie'

class DecisionState

  def initialize **args
    @state = args
  end

  def respond_to? name
    @state.has_key? name || super
  end

  def method_missing name, *args
    super unless respond_to? name
    @state[name] if args.empty?
    super
  end

  def decision= arg
    @state[:decision] = arg
  end

  def possible_attributes
    [:next_state, :branch_state, :decision, :command, :message]
  end

  def next_state *args
    return branch_state if decision && decision.call(*args)
    @state[:next_state]
  end
end
