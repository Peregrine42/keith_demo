require_relative '../connection'

describe Connection, '#puts' do
  it 'sends a message without waiting for a response' do
    ssh = double(:ssh_connection)
    expect(ssh).to receive :puts
    Connection.new(ssh).puts("hi")
  end
end

describe Connection, '#puts_and_wait_for_prompt' do
  context 'a prompt string given' do
    it 'sends a message and waits for the prompt' do
      ssh = double(:ssh_connection)
      allow(ssh).to receive(:puts).ordered
      expect(ssh).to receive(:waitfor).with("a_prompt>").ordered
      Connection.new(ssh).puts_and_wait_for_prompt("hi", "a_prompt>")
    end
  end

  context 'no prompt string given' do
    it 'sends a message and waits for the prompt passed in at initialization' do
      ssh = double(:ssh_connection)
      allow(ssh).to receive(:puts).ordered
      expect(ssh).to receive(:waitfor).with("a_default_prompt>").ordered
      Connection.new(ssh, "a_default_prompt>").puts_and_wait_for_prompt("hi")
    end

    context 'no default given' do
      it 'raises an error' do
        ssh = double(:ssh_connection)
        allow(ssh).to receive(:puts).ordered
        connection = Connection.new(ssh)
        expect { connection.puts_and_wait_for_prompt("hi") }.to raise_error Connection::Error, 'no prompt given'
      end
    end
  end
end
