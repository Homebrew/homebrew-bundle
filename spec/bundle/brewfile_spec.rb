# frozen_string_literal: true

require "spec_helper"

describe Bundle::Brewfile do
  describe "path" do
    let(:env_bundle_file_value) { nil }
    let(:file_value) { "" }
    let(:has_global) { false }

    before do
      allow(ARGV).to receive(:value).with("file").and_return(file_value)
      allow(ARGV).to receive(:include?).with("--global").and_return(has_global)

      original_method = ENV.method(:[])
      allow(ENV).to receive(:[]) do |env_string|
        case env_string
        when "HOMEBREW_BUNDLE_FILE"
          env_bundle_file_value
        else
          original_method.call(env_string)
        end
      end
    end

    context "when `--file` is passed" do
      context "with a relative path" do
        let(:file_value) { "path/to/Brewfile" }
        let(:expected_pathname) { Pathname.new(file_value).expand_path(Dir.pwd) }

        it "returns the expected path" do
          expect(described_class.path).to eq(expected_pathname)
        end

        context "and HOMEBREW_BUNDLE_FILE is set" do
          let(:env_bundle_file_value) { "/path/to/Brewfile" }

          it "returns the value specified by `--file` path" do
            expect(described_class.path).to eq(expected_pathname)
          end
        end

        context "and HOMEBREW_BUNDLE_FILE is `` (empty)" do
          let(:env_bundle_file_value) { "" }

          it "returns the value specified by `--file` path" do
            expect(described_class.path).to eq(expected_pathname)
          end
        end
      end

      context "with an absolute path" do
        let(:file_value) { "/tmp/random_file" }
        let(:expected_pathname) { Pathname.new(file_value) }

        it "returns the expected path" do
          expect(described_class.path).to eq(expected_pathname)
        end

        context "and HOMEBREW_BUNDLE_FILE is set" do
          let(:env_bundle_file_value) { "/path/to/Brewfile" }

          it "returns the value specified by `--file` path" do
            expect(described_class.path).to eq(expected_pathname)
          end
        end

        context "and HOMEBREW_BUNDLE_FILE is `` (empty)" do
          let(:env_bundle_file_value) { "" }

          it "returns the value specified by `--file` path" do
            expect(described_class.path).to eq(expected_pathname)
          end
        end
      end

      context "with `-`" do
        let(:file_value) { "-" }
        let(:expected_pathname) { Pathname.new("/dev/stdin") }

        it "returns stdin by default" do
          allow(ARGV).to receive(:include?).with("dump").and_return(false)
          expect(described_class.path).to eq(expected_pathname)
        end

        context "and HOMEBREW_BUNDLE_FILE is set" do
          let(:env_bundle_file_value) { "/path/to/Brewfile" }

          it "returns the value specified by `--file` path" do
            expect(described_class.path).to eq(expected_pathname)
          end
        end

        context "and HOMEBREW_BUNDLE_FILE is `` (empty)" do
          let(:env_bundle_file_value) { "" }

          it "returns the value specified by `--file` path" do
            expect(described_class.path).to eq(expected_pathname)
          end
        end

        context "when `dash_writes_to_stdout` is true" do
          let(:expected_pathname) { Pathname.new("/dev/stdout") }

          it "returns stdout" do
            expect(described_class.path(dash_writes_to_stdout: true)).to eq(expected_pathname)
          end
        end

        context "when `dash_writes_to_stdout` is true and HOMEBREW_BUNDLE_FILE is set" do
          let(:expected_pathname) { Pathname.new("/dev/stdout") }
          let(:env_bundle_file_value) { "/path/to/Brewfile" }

          it "returns the value specified by `--file` path" do
            expect(described_class.path(dash_writes_to_stdout: true)).to eq(expected_pathname)
          end
        end

        context "when `dash_writes_to_stdout` is true and HOMEBREW_BUNDLE_FILE is `` (empty)" do
          let(:expected_pathname) { Pathname.new("/dev/stdout") }
          let(:env_bundle_file_value) { "" }

          it "returns the value specified by `--file` path" do
            expect(described_class.path(dash_writes_to_stdout: true)).to eq(expected_pathname)
          end
        end
      end
    end

    context "when `--global` is passed" do
      let(:has_global) { true }
      let(:expected_pathname) { Pathname.new("#{ENV["HOME"]}/.Brewfile") }

      it "returns the expected path" do
        expect(described_class.path).to eq(expected_pathname)
      end

      context "and HOMEBREW_BUNDLE_FILE is set" do
        let(:env_bundle_file_value) { "/path/to/Brewfile" }

        it "returns the value specified by `--file` path" do
          expect { described_class.path }.to raise_error(RuntimeError)
        end
      end

      context "and HOMEBREW_BUNDLE_FILE is `` (empty)" do
        let(:env_bundle_file_value) { "" }

        it "returns the value specified by `--file` path" do
          expect(described_class.path).to eq(expected_pathname)
        end
      end
    end

    context "and HOMEBREW_BUNDLE_FILE has a value" do
      let(:env_bundle_file_value) { "/path/to/Brewfile" }

      it "returns the expected path" do
        expect(described_class.path).to eq(Pathname.new(env_bundle_file_value))
      end

      context "that is `` (empty)" do
        let(:env_bundle_file_value) { "" }

        it "defaults to `${PWD}/Brewfile`" do
          expect(described_class.path).to eq(Pathname.new("Brewfile").expand_path(Dir.pwd))
        end
      end

      context "that is `nil`" do
        let(:env_bundle_file_value) { nil }

        it "defaults to `${PWD}/Brewfile`" do
          expect(described_class.path).to eq(Pathname.new("Brewfile").expand_path(Dir.pwd))
        end
      end
    end
  end
end
