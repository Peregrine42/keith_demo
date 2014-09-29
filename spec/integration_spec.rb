require_relative '../keith'
require_relative '../state'
require_relative '../pipe'
require_relative '../connection'

describe do

  let(:set_catos_prompt)           { SendCommand.new(args: 'set prompt device_name>') }
  let(:set_ios_prompt)             { SendCommand.new(args: 'prompt=device_name>') }

  let(:try_setting_catos_terminal) { TryCommand.new(args: 'set terminal 0',   error_matcher: /Invalid/,           success_step: nil, error_step: nil) }
  let(:try_setting_ios_terminal)   { TryCommand.new(args: 'term len 0',       error_matcher: /Not valid command/, success_step: nil, error_step: nil) }

  let(:get_catos_power)            { GetInfo.new(args: 'show total power', extract: /Total Power Consumption: (\d+)/)     }
  let(:get_ios_power)              { GetInfo.new(args: 'display power',    extract: /Interface Power Consumption: (\d+)/) }

  let(:get_catos_ports)            { GetCatosPorts.new }
  let(:get_ios_ports)              { GetIosPorts.new   }

  before do
    first_catos_process = keith.make_sequence(get_catos_power, get_catos_ports)
    first_ios_process   = keith.make_sequence(get_ios_power, get_ios_ports)

    keith.add        login

    keith.add        set_catos_prompt
    keith.add        set_ios_prompt
    keith.add_branch try_setting_catos_terminal, on_success_use: catos_process_head
    keith.add_branch try_setting_ios_terminal,   on_success_use: ios_process_head

    keith.link       first_catos_process.chain_end, to: logoff
    keith.link       first_ios_process.chain_end,   to: logoff
  end

  def call message
    expect(ssh).to receive(:puts   ).with(message).ordered
  end

  def respond message
    expect(ssh).to receive(:waitfor).with(/prompt>/).and_return(message).ordered
  end

  it "can detect an ios switch with a strange prompt" do
       call "set prompt prompt>"

       call "set length 0"
    respond "That command was Invalid"

       call "term len 0"
    respond ""

       call "power consumption"
    respond "Total Power Consumption: 600W\nBreakdown: blah blah"

    expect(keith.walk).to eq [600]
  end

  it "can detect a catos switch" do
       call "set prompt prompt>"

       call "set length 0"
    respond ""

       call "show power consumption"
    respond "Power Consumption: 500W\nBreakdown: blah blah"

    expect(keith.walk).to eq [500]
  end

  it "breaks if nothing works" do
       call "set prompt prompt>"

       call "set length 0"
    respond "That command was Invalid"

       call "term len 0"
    respond "That command was Not good"

    expect { keith.walk }.to raise_error Exception, "can't detect switch type"
  end
end
