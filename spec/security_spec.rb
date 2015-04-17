require "spec_helper"

describe Bundle::Dsl do
  it "raises error if there is system call" do
    expect { Bundle::Dsl.new("system 'whomai'") }.to raise_error(SecurityError)
    expect { Bundle::Dsl.new("Kernel.system 'whomai'") }.to raise_error(SecurityError)
    expect { Bundle::Dsl.new("IO.popen 'whomai'") }.to raise_error(SecurityError)
  end

  it "raises error if there is backtick" do
    expect { Bundle::Dsl.new("`whomai`") }.to raise_error(SecurityError)
  end

  it "raises error if it tries to open file" do
    expect { Bundle::Dsl.new("File.open('/tmp/bomb')") }.to raise_error(SecurityError)
  end
end
