require "spec_helper"

describe Brewdler::BrewDumper do
  context "when brew is not installed" do
    it "raises an error" do
      allow(Brewdler).to receive(:brew_installed?).and_return(false)
      expect { Brewdler::BrewDumper.new }.to raise_error
    end
  end

  context "when no formula is installed" do
    before do
      allow(Brewdler).to receive(:brew_installed?).and_return(true)
      allow_any_instance_of(Brewdler::BrewDumper).to receive(:`).and_return("[]")
    end
    subject { Brewdler::BrewDumper.new }

    it "return empty list" do
      expect(subject.formulae).to be_empty
    end

    it "dump as empty string" do
      expect(subject.to_s).to eql("")
    end
  end

  context "formulae `foo` and `bar` are installed" do
    before do
      allow(Brewdler).to receive(:brew_installed?).and_return(true)
      allow(JSON).to receive(:load).and_return [
        {
          "name" => "foo",
          "versions" => {"stable" => "1.0", "bottle" => false, "devel" => nil, "head" => "HEAD"},
          "installed" => [ { "version" => "1.0", "used_options" => [] }, ],
          "linked_keg" => "1.0",
        },
        {
          "name" => "bar",
          "versions" => {"stable" => "2.0", "bottle" => false, "devel" => nil, "head" => "HEAD"},
          "installed" => [ { "version" => "2.0", "used_options" => ["--with-a", "--with-b"] }, ],
          "linked_keg" => "2.0",
        },
      ]
    end
    subject { Brewdler::BrewDumper.new }

    it "return foo and bar with their information" do
      expect(subject.formulae).to eql([{:name=>"foo", :args=>[], :version=>"1.0"}, {:name=>"bar", :args=>["with-a", "with-b"], :version=>"2.0"}])
    end

    it "dump as foo and bar with args" do
      expect(subject.to_s).to eql("brew 'foo'\nbrew 'bar', args: ['with-a', 'with-b']")
    end
  end

  context "HEAD and devel formulae are installed" do
    before do
      allow(Brewdler).to receive(:brew_installed?).and_return(true)
      allow(JSON).to receive(:load).and_return [
        {
          "name" => "foo",
          "versions" => {"stable" => "1.0", "bottle" => false, "devel" => "1.1beta", "head" => "HEAD"},
          "installed" => [ { "version" => "1.1beta", "used_options" => [] }, ],
          "linked_keg" => "1.1beta",
        },
        {
          "name" => "bar",
          "versions" => {"stable" => "2.0", "bottle" => false, "devel" => nil, "head" => "HEAD"},
          "installed" => [ { "version" => "HEAD", "used_options" => [] }, ],
          "linked_keg" => "HEAD",
        },
      ]
    end
    subject { Brewdler::BrewDumper.new.formulae }

    it "return with args `devel` and `HEAD`" do
      expect(subject[0][:args]).to include("devel")
      expect(subject[1][:args]).to include("HEAD")
    end
  end

  context "A formula link to the old keg" do
    before do
      allow(Brewdler).to receive(:brew_installed?).and_return(true)
      allow(JSON).to receive(:load).and_return [
        {
          "name" => "foo",
          "versions" => {"stable" => "2.0", "bottle" => false, "devel" => nil, "head" => "HEAD"},
          "installed" => [
            { "version" => "1.0", "used_options" => [] },
            { "version" => "2.0", "used_options" => [] },
          ],
          "linked_keg" => "1.0",
        },
      ]
    end
    subject { Brewdler::BrewDumper.new.formulae }

    it "return with linked keg" do
      expect(subject[0][:version]).to eql("1.0")
    end
  end

  context "A formula with no linked keg" do
    before do
      allow(Brewdler).to receive(:brew_installed?).and_return(true)
      allow(JSON).to receive(:load).and_return [
        {
          "name" => "foo",
          "versions" => {"stable" => "2.0", "bottle" => false, "devel" => nil, "head" => "HEAD"},
          "installed" => [
            { "version" => "1.0", "used_options" => [] },
            { "version" => "2.0", "used_options" => [] },
          ],
          "linked_keg" => nil,
        },
      ]
    end
    subject { Brewdler::BrewDumper.new.formulae }

    it "return with last one" do
      expect(subject[0][:version]).to eql("2.0")
    end
  end
end
