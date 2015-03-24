require "spec_helper"

describe Brewdler::Dsl do
  it "raises error if there is system call" do
    expect { Brewdler::Dsl.new("system 'whomai'") }.to raise_error(SecurityError)
    expect { Brewdler::Dsl.new("Kernel.system 'whomai'") }.to raise_error(SecurityError)
    expect { Brewdler::Dsl.new("IO.popen 'whomai'") }.to raise_error(SecurityError)
  end

  it "raises error if there is backtick" do
    expect { Brewdler::Dsl.new("`whomai`") }.to raise_error(SecurityError)
  end

  it "raises error if it tries to open file" do
    expect { Brewdler::Dsl.new("File.open('/tmp/bomb')") }.to raise_error(SecurityError)
  end
end
