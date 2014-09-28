require_relative '../state'

describe DecisionState do
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

  it 'can have its branch state set' do
    subject = described_class.new
    subject.branch_state = "new state"
    expect(subject.branch_state).to eq "new state"
  end

  it 'can have its decision set' do
    subject = described_class.new
    subject.decision = "new state"
    expect(subject.decision).to eq "new state"
  end

  it 'has two possible states' do
    expect(described_class.new(branch_state: "hi").branch_state).to eq "hi"
  end

  it 'can have a decision proc that decides whether to return one state or the other' do
    subject = described_class.new branch_state: "correct", next_state: "wrong"
    subject.decision = Proc.new { |pipe_response| !pipe_response.match(/Invalid/) }
    expect(subject.next_state('good response')).to eq "correct"
  end

  it 'evaluates the result if the result is a proc' do
    subject = described_class.new result: Proc.new { |response| response.match(/^response (\w+)/).to_a[1] }
    expect(subject.result("response good")).to eq "good"
  end
end
