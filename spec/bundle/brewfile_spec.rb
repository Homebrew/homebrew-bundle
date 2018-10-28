# frozen_string_literal: true

require "spec_helper"

describe Bundle::Brewfile do
  describe "path" do
    context "when `--file` is passed" do
      before do
        allow(ARGV).to receive(:include?).with("--global").and_return(false)
        allow(ARGV).to receive(:value).with("file").and_return(file_value)
      end

      context "with a relative path" do
        let(:file_value) { "path/to/Brewfile" }

        it "returns the expected path" do
          expect(described_class.path).to eq(Pathname.new("path/to/Brewfile").expand_path(Dir.pwd))
        end
      end

      context "with an absolute path" do
        let(:file_value) { "/tmp/random_file" }

        it "returns the expected path" do
          expect(described_class.path).to eq(Pathname.new("/tmp/random_file"))
        end
      end

      context "with `-`" do
        let(:file_value) { "-" }

        it "returns the expected path" do
          expect(described_class.path).to eq(Pathname.new("/dev/stdin"))
        end
      end
    end

    context "when `--global` is passed" do
      before do
        allow(ARGV).to receive(:include?).with("--global").and_return(true)
      end

      it "returns the expected path" do
        expect(described_class.path).to eq(Pathname.new("#{ENV["HOME"]}/.Brewfile"))
      end
    end
  end
end
