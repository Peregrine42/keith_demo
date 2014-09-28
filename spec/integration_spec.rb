require_relative '../keith'
require_relative '../state'
require_relative '../pipe'
require_relative '../connection'

describe do

  it "can detect the operating system of a switch" do
    catos_check = State.new(message: "set length 0",
                            decision: Proc.new { |response| puts "yup!"; !response.match(/Invalid/) })
    ios_check   = State.new(message: "term len 0",
                            decision: Proc.new { |response| !response.match(/Not good/) })

    catos_first_step = State.new
    ios_first_step   = State.new

    catos_power = State.new(message: "show power consumption",
                            result:  Proc.new { |response| response.match(/Power Consumption: (\d+)/).to_a[1] })
    ios_power   = State.new(message: "power consumption",
                            result:  Proc.new { |response| response.match(/Total Power Consumption: (\d+)/).to_a[1] })

    detection_failed = State.new result: Proc.new { |response| raise Exception, "can't detect switch type" }

    catos_check.next_step   = ios_check
    catos_check.branch_step = catos_first_step

    ios_check.next_step     = detection_failed
    ios_check.branch_step   = ios_first_step

    catos_first_step.next_step = catos_power
    ios_first_step.next_step   = ios_power

    ssh = double(:ssh)
    expect(ssh).to receive(:puts   ).with("set length 0").ordered
    expect(ssh).to receive(:waitfor).with(/prompt>/).and_return("That command was Invalid").ordered

    expect(ssh).to receive(:puts   ).with("term len 0").ordered
    expect(ssh).to receive(:waitfor).with(/prompt>/).and_return("").ordered

    expect(ssh).to receive(:puts   ).with("power consumption").ordered
    expect(ssh).to receive(:waitfor).with(/prompt>/).and_return("Total Power Consumption: 600W\nBreakdown: blah blah").ordered

    connection = Connection.new(ssh, 'prompt>')
    pipe = Pipe.new(connection)

    keith = Keith.new(pipe, :puts_and_wait_for_prompt)
    keith.state = catos_check
    keith.walk
  end

end
