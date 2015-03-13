require "spec_helper"

describe Brewdler::Dsl do
  it "raises error if there is system call" do
    dsl = Brewdler::Dsl.new("system 'whomai'")
    expect { dsl.process }.to raise_error(SecurityError)

    dsl = Brewdler::Dsl.new("Kernel.system 'whomai'")
    expect { dsl.process }.to raise_error(SecurityError)

    dsl = Brewdler::Dsl.new("IO.popen 'whomai'")
    expect { dsl.process }.to raise_error(SecurityError)
  end

  it "raises error if there is backtick" do
    dsl = Brewdler::Dsl.new("`whomai`")
    expect { dsl.process }.to raise_error(SecurityError)
  end

  it "raises error if it tries to open file" do
    dsl = Brewdler::Dsl.new("File.open('/tmp/bomb')")
    expect { dsl.process }.to raise_error(SecurityError)
  end
end
