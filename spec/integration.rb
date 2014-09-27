require_relative '../keith'
require_relative '../state'
require_relative '../pipe'
require_relative '../connection'

describe do

  it "can detect the operating system of a switch" do
    catos_check = DecisionState.new(message: "set len 0",
                                    next_state: ios_check,
                                    branch_state: catos_steps,
                                    decision: Proc.new { |response| !response.match(/Invalid/) })
  end

end
