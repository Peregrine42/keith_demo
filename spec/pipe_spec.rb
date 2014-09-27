require_relative '../pipe'

describe Pipe, '#puts' do
  it 'sends a string down the connection' do
    connection = double(:connection)
    expect(connection).to receive(:puts).with "hi"
    Pipe.new(connection).puts "hi"
  end

  it 'raises an exception if the connection takes too long to respond' do
    connection = double(:connection)
    allow(connection).to receive(:puts).with("hi")
    allow(Timeout).to receive(:timeout).with(10).and_raise Timeout::Error.new

    pipe = Pipe.new(connection)
    expect { pipe.puts("hi") }.to raise_error Pipe::TimeoutError, "hi"
  end
end

class Pipe::TimeoutError < StandardError
end
