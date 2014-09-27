require_relative '../state'

shared_examples_for "state" do

  it 'optionally has a message' do
    expect(described_class.new(message: "hi").message).to eq "hi"
  end

  it 'optionally has a next state' do
    expect(described_class.new(next_state: "hi").next_state).to eq "hi"
  end

  it 'optionally has a result' do
    expect(described_class.new(result: "hi").result).to eq "hi"
  end

  it 'optionally has a command' do
    expect(described_class.new(command: "hi").command).to eq "hi"
  end

  it 'can have its next state set' do
    subject = described_class.new
    subject.next_state = "new state"
    expect(subject.next_state).to eq "new state"
  end
end

describe DecisionState do
  it_behaves_like "state"

  it 'has two possible states' do
    expect(described_class.new(branch_state: "hi").branch_state).to eq "hi"
  end

  it 'can have a proc that decides whether to return one state or the other' do
    subject = described_class.new branch_state: "correct", next_state: "wrong"
    subject.decision = Proc.new { |pipe_response| !pipe_response.match(/Invalid/) }
    expect(subject.next_state('good response')).to eq "correct"
  end
end
