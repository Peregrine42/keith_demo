require_relative '../keith'

describe Keith do

  it 'returns the result of visiting the given step' do
    state = double(:step, name: "step 1", next: nil, result: "foo")
    keith = Keith.new(state)
    expect(keith.walk).to eq "foo"
  end

  it 'moves to the next step until the next step is nil' do
    state2 = double(:step2, name: "step 2", next: nil,    result: "bar")
    state1 = double(:step1, name: "step 1", next: state2)
    keith = Keith.new(state1)
    expect(keith.walk).to eq "bar"
  end

  it "sends each state's name down the pipe" do
    state2 = double(:step2, name: "step 2", next: nil,  )
    state1 = double(:step1, name: "step 1", next: state2)
    pipe   = double(:pipe)
    expect(pipe).to receive(:puts).with("step 1").ordered
    expect(pipe).to receive(:puts).with("step 2").ordered
    keith = Keith.new(state1, pipe)
    keith.walk
  end

  it "makes a descision on the next step to take based on the response of pipe" do
    state3 = double(:step3, name: "step 3", next: nil)
    state2 = double(:step2, name: "step 2", next: nil)
    state1 = double(:step1, name: "step 1", next: {/yes/ => state3, // => state2 })
    pipe   = double(:pipe)
    expect(pipe).to receive(:puts).with("step 1").and_return("yes")
    expect(pipe).to receive(:puts).with("step 3")
    expect(pipe).to_not receive(:puts).with("step 2")
    keith = Keith.new(state1, pipe)
    keith.walk
  end

  it "walks through a cat os network process" do
    cat_os_power_usage = double(:step2b, name: "show power comm", next: nil, result: { ports_used: 5, ports_total: 10, power_usage: 50 } )
    i_os_power_usage   = double(:step2a, name: "get power comm",  next: nil)
    terminal_length = double(:step1, name: "set length 0", next: { /Invalid/ => i_os_power_usage, // => cat_os_power_usage })
    pipe   = double(:pipe)

    expect(pipe).to receive(:puts).with("set length 0").and_return(">")
    expect(pipe).to receive(:puts).with("show power comm")
    expect(pipe).to_not receive(:puts).with("get power comm")

    keith = Keith.new(terminal_length, pipe)
    expect(keith.walk).to eq({ ports_used: 5, ports_total: 10, power_usage: 50 })
  end

  it "walks through a i os network process" do
    cat_os_power_usage = double(:step2b, name: "show power comm", next: nil, result: :wrong_way)
    i_os_power_usage   = double(:step2a, name: "get power comm",  next: nil, result: { ports_used: 5, ports_total: 10, power_usage: 50 } )
    terminal_length = double(:step1, name: "set length 0", next: { /Invalid/ => i_os_power_usage, // => cat_os_power_usage })
    pipe   = double(:pipe)

    expect(pipe).to receive(:puts).with("set length 0").and_return("Invalid")
    expect(pipe).to receive(:puts).with("get power comm")
    expect(pipe).to_not receive(:puts).with("show power comm")

    keith = Keith.new(terminal_length, pipe)
    expect(keith.walk).to eq({ ports_used: 5, ports_total: 10, power_usage: 50 })
  end
end
