require_relative '../keith'
require_relative '../state'
require_relative '../pipe'
require_relative '../connection'

describe do

  it "can detect the operating system of a switch" do
    catos_check = State.new(message: "set length 0",
                            decision: Proc.new { |response| !response.match(/Invalid/) })
    ios_check   = State.new(message: "term len 0",
                            decision: Proc.new { |response| !response.match(/Invalid/) })
    catos_first_step = State.new
    ios_first_step   = State.new

    catos_power = State.new(message: "show power consumption",
                            result:  Proc.new { |response, result| result[:power] = response.match(/Power Consumption: (\d+)/).to_a[0] })
    ios_power   = State.new(message: "power consumption",
                            result:  Proc.new { |response, result| result[:power] = response.match(/Total Power Consumption: (\d+)/).to_a[0] })
  end

end
