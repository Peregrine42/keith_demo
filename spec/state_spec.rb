require_relative '../state'

describe State do
  it 'optionally has a message' do
    expect(described_class.new(message: "hi").message).to eq "hi"
  end

  it 'optionally has a next step' do
    expect(described_class.new(next_step: "hi").next_step).to eq "hi"
  end

  it 'optionally has a result' do
    expect(described_class.new(result: "hi").result).to eq "hi"
  end

  it 'optionally has a command' do
    expect(described_class.new(command: "hi").command).to eq "hi"
  end

  it 'optionally has a command' do
    expect(described_class.new(decision: "hi").decision).to eq "hi"
  end

  it 'can have its next step set' do
    subject = described_class.new
    subject.next_step = "new step"
    expect(subject.next_step).to eq "new step"
  end

  it 'can have its branch step set' do
    subject = described_class.new
    subject.branch_step = "new step"
    expect(subject.branch_step).to eq "new step"
  end

  it 'can have its decision set' do
    subject = described_class.new
    subject.decision = "new step"
    expect(subject.decision).to eq "new step"
  end

  it 'has two possible step' do
    expect(described_class.new(branch_step: "hi").branch_step).to eq "hi"
  end

  it 'can have a decision proc that decides whether to return one step or the other' do
    subject = described_class.new branch_step: "correct", next_step: "wrong"
    subject.decision = Proc.new { |pipe_response| !pipe_response.match(/Invalid/) }
    expect(subject.next_step('good response')).to eq "correct"
  end

  it 'evaluates the result if the result is a proc' do
    subject = described_class.new result: Proc.new { |response| response.match(/^response (\w+)/).to_a[1] }
    expect(subject.result("response good")).to eq "good"
  end
end
