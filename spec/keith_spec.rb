require_relative '../keith'

describe Keith do

  it 'returns the result of visiting the given step' do
    state = double(:step, name: "step 1", next: nil)
    keith = Keith.new(state)
    expect(keith.walk([])).to eq ["step 1"]
  end

  it 'moves to the next step until the next step is nil' do
    state2 = double(:step2, name: "step 2", next: nil)
    state1 = double(:step1, name: "step 1", next: state2)
    keith = Keith.new(state1)
    expect(keith.walk([])).to eq ["step 1", "step 2"]
  end

  it "sends each state's name down the pipe" do
    state2 = double(:step2, name: "step 2", next: nil)
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
    state1 = double(:step1, name: "step 1", next: {"yes" => state3, "no" => state2 })
    pipe   = double(:pipe)
    expect(pipe).to receive(:puts).with("step 1").and_return("yes")
    expect(pipe).to receive(:puts).with("step 3")
    expect(pipe).to_not receive(:puts).with("step 2")
    keith = Keith.new(state1, pipe)
    keith.walk

  end
end
