# frozen_string_literal: true

require "spec_helper"

describe Bundle::MacAppStoreDumper do
  context "when mas is not installed" do
    before do
      Bundle::MacAppStoreDumper.reset!
      allow(Bundle).to receive(:mas_installed?).and_return(false)
    end
    subject { Bundle::MacAppStoreDumper }

    it "returns empty list" do
      expect(subject.apps).to be_empty
    end

    it "dumps as empty string" do
      expect(subject.dump).to eql("")
    end
  end

  context "when there is no apps" do
    before do
      Bundle::MacAppStoreDumper.reset!
      allow(Bundle).to receive(:mas_installed?).and_return(true)
      allow(Bundle::MacAppStoreDumper).to receive(:`).and_return("")
    end
    subject { Bundle::MacAppStoreDumper }

    it "returns empty list" do
      expect(subject.apps).to be_empty
    end

    it "dumps as empty string" do
      expect(subject.dump).to eql("")
    end
  end

  context "apps `foo`, `bar` and `baz` are installed" do
    before do
      Bundle::MacAppStoreDumper.reset!
      allow(Bundle).to receive(:mas_installed?).and_return(true)
      allow(Bundle::MacAppStoreDumper).to receive(:`).and_return("123 foo\n456 bar\n789 baz")
    end
    subject { Bundle::MacAppStoreDumper }

    it "returns list %w[foo bar baz]" do
      expect(subject.apps).to eql([["123", "foo"], ["456", "bar"], ["789", "baz"]])
    end
  end

  context "with invalid app details" do
    let(:invalid_mas_output) do
      <<~HEREDOC
        497799835 Xcode (9.2)
        425424353 The Unarchiver (4.0.0)
        08981434 iMovie (10.1.8)
         Install macOS High Sierra (13105)
        409201541 Pages (7.1)
        123456789 123AppNameWithNumbers (1.0)
        409203825 Numbers (5.1)
      HEREDOC
    end

    let(:expected_app_details_array) do
      [
        ["497799835", "Xcode"],
        ["425424353", "The Unarchiver"],
        ["08981434", "iMovie"],
        ["409201541", "Pages"],
        ["123456789", "123AppNameWithNumbers"],
        ["409203825", "Numbers"],
      ]
    end

    let(:expected_mas_dumped_output) do
      <<~HEREDOC
        mas "123AppNameWithNumbers", id: 123456789
        mas "iMovie", id: 08981434
        mas "Numbers", id: 409203825
        mas "Pages", id: 409201541
        mas "The Unarchiver", id: 425424353
        mas "Xcode", id: 497799835
      HEREDOC
    end

    before do
      Bundle::MacAppStoreDumper.reset!
      allow(Bundle).to receive(:mas_installed?).and_return(true)
      allow(Bundle::MacAppStoreDumper).to receive(:`).and_return(invalid_mas_output)
    end
    subject { Bundle::MacAppStoreDumper }

    it "returns only valid apps" do
      expect(subject.apps).to eql(expected_app_details_array)
    end

    it "dumps excluding invalid apps" do
      expect(subject.dump).to eq(expected_mas_dumped_output.strip)
    end
  end
end
