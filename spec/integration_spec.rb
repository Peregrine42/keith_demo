require_relative '../keith'
require_relative '../state'
require_relative '../pipe'
require_relative '../connection'

describe do

  let(:catos_check)      { State.new(message: "set length 0", decision: Proc.new { |response| !response.match(/Invalid/)  }) }
  let(:ios_check)        { State.new(message: "term len 0",   decision: Proc.new { |response| !response.match(/Not good/) }) }
  let(:catos_first_step) { State.new }
  let(:ios_first_step)   { State.new }
  let(:catos_power)      { State.new(message: "show power consumption", result:  Proc.new { |response| response.match(/Power Consumption: (\d+)/).to_a[1].to_i })  }
  let(:ios_power)        { State.new(message: "power consumption", result:  Proc.new { |response| response.match(/Total Power Consumption: (\d+)/).to_a[1].to_i }) }
  let(:detection_failed) { State.new(result: Proc.new { |response| raise Exception, "can't detect switch type" }) }

  let(:ssh)              { double(:ssh) }

  let(:connection) { Connection.new(ssh, 'prompt>') }
  let(:pipe)       { Pipe.new(connection) }
  let(:keith)      { Keith.new(pipe, :puts_and_wait_for_prompt) }

  before do
    catos_check.next_step   = ios_check
    catos_check.branch_step = catos_first_step

    ios_check.next_step     = detection_failed
    ios_check.branch_step   = ios_first_step

    catos_first_step.next_step = catos_power
    ios_first_step.next_step   = ios_power

    keith.state = catos_check
  end

  def call message
    expect(ssh).to receive(:puts   ).with(message).ordered
  end

  def respond message
    expect(ssh).to receive(:waitfor).with(/prompt>/).and_return(message).ordered
  end

  it "can detect an ios switch" do

       call "set length 0"
    respond "That command was Invalid"

       call "term len 0"
    respond ""

       call "power consumption"
    respond "Total Power Consumption: 600W\nBreakdown: blah blah"

    expect(keith.walk).to eq [600]
  end

  it "can detect a catos switch" do
       call "set length 0"
    respond ""

       call "show power consumption"
    respond "Power Consumption: 500W\nBreakdown: blah blah"

    expect(keith.walk).to eq [500]
  end

  it "breaks if nothing works" do
       call "set length 0"
    respond "That command was Invalid"

       call "term len 0"
    respond "That command was Not good"

    expect { keith.walk }.to raise_error Exception, "can't detect switch type"
  end
end
