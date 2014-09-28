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
    expect(keith.walk).to eq ["bar"]
  end

  it 'returns the result of visiting the last given step' do
    state = double(:step, message: "step 1", result: "foo")
    keith.state = state
    expect(keith.walk).to eq ["foo"]
  end

  context "the current state has a result" do
    it 'calls the result with the reponse from the pipe' do
      state1 = double(:state1)
      state2 = double(:state2, message: "a message to get a reponse")

      allow(pipe).to receive(:puts).and_return "a pipe response"
      allow(state1).to receive(:next_state).and_return(state2)
      expect(state2).to receive(:result).with("a pipe response")

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
