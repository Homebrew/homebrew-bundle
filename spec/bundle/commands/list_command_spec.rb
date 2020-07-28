# frozen_string_literal: true

require "spec_helper"

describe Bundle::Commands::List do
  subject(:list) { described_class.run(**options) }

  let(:options) { {} }

  before do
    allow_any_instance_of(IO).to receive(:puts)
  end

  context "outputs dependencies to stdout" do
    before do
      allow_any_instance_of(Pathname).to receive(:read).and_return \
        "tap 'phinze/cask'\nbrew 'mysql', " \
        "conflicts_with: ['mysql56']\ncask 'google-chrome'\nmas '1Password', id: 443987910"
    end

    it "only shows brew deps when no options are passed" do
      expect { list }.to output("mysql\n").to_stdout
    end

    context "limiting when certain options are passed" do
      types_and_deps = {
        taps:  "phinze/cask",
        brews: "mysql",
        casks: "google-chrome",
        mas:   "1Password",
      }

      combinations = 1.upto(types_and_deps.length).flat_map do |i|
        types_and_deps.keys.combination(i).take((1..types_and_deps.length).inject(:*) || 1)
      end.sort

      combinations.each do |options_list|
        args_hash = options_list.map { |arg| [arg, true] }.to_h
        words = options_list.join(" and ")
        opts = options_list.map { |o| "`#{o}`" }.join(" and ")
        verb = options_list.length == 1 && "is" || "are"

        context "when #{opts} #{verb} passed" do
          let(:options) { args_hash }

          it "shows only #{words}" do
            expected = options_list.map { |opt| types_and_deps[opt] }.join("\n")
            expect { list }.to output("#{expected}\n").to_stdout
          end
        end
      end
    end
  end
end
