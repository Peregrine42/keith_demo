require_relative '../keith'

describe Keith, '#walk' do

  let(:pipe)  { double(:pipe, puts: "some pipe response") }
  let(:keith) { Keith.new pipe }

  it "sends each state's message down the pipe" do
    state = double(:step1, message: "step 1")

    expect(pipe).to receive(:puts).with("step 1")

    keith.state = state
    keith.walk
  end

  it 'moves to the next step until a step with no next step is reached' do
    state2 = double(:step2, message: "step 2", result: "bar")
    state1 = double(:step1, message: "step 1", next_state: state2)
    keith.state = state1
    expect(keith.walk).to eq "bar"
  end

  it 'returns the result of visiting the last given step' do
    state = double(:step, message: "step 1", result: "foo")
    keith.state = state
    expect(keith.walk).to eq "foo"
  end

  context "when there has been no result up until now" do
    it "passes :no_result to the current state" do
      state = double(:step, message: "step 1")
      allow(pipe).to   receive(:puts).and_return("pipe response")

      expect(state).to receive(:result).with(:no_result, "pipe response")

      keith.state = state
      keith.walk
    end
  end

  context "when there has been a result from a previous state" do
    it "passes that result to the current state" do
      state2 = double(:step2, message: "step 2", result: "bar")
      state1 = double(:step1, message: "step 1", next_state: state2)
      allow(state1).to receive(:result).and_return("step 1 result")

      expect(state2).to receive(:result).with("step 1 result", "some pipe response")

      keith.state = state1
      keith.walk
    end
  end

  context "when the current state has no message for the pipe" do
    it "calls next_state on the current state with :no_response" do
      state1 = double(:state1, result: "foo")
      state2 = double(:state2, result: "foo")

      expect(state1).to receive(:next_state).with(:no_response).and_return(state2)

      keith.state = state1
      keith.walk
    end
  end

  context "when the pipe has a response" do
    it "calls next_state on the current state with the pipe's last response" do
      state1 = double(:state1, message: "step 1", result: "foo")
      state2 = double(:state2, message: "step 2", result: "bar")
      allow(pipe).to receive(:puts).and_return("pipe response")

      expect(state1).to receive(:next_state).with("pipe response").and_return(state2)

      keith.state = state1
      keith.walk
    end
  end

  it "can send the connection a custom message" do
    state = double(:step1, command: :foo, message: "step 1")

    expect(pipe).to receive(:foo).with("step 1")

    keith.state = state
    keith.walk
  end
end
