require "safebox/cli"

describe Safebox::CLI do
  let(:cli) { Safebox::CLI.new }

  describe "safebox" do
    around do |example|
      stdout, $stdout = $stdout, StringIO.new("")
      stderr, $stderr = $stderr, StringIO.new("")

      example.run

      $stdout = stdout
      $stderr = stderr
    end

    let(:stdout) { $stdout }
    let(:stderr) { $stderr }

    describe "list" do
      it "lists all keys and values" do
        cli.run("list")
      end
    end

    describe "get" do
    end

    describe "set" do
    end

    describe "delete" do
    end
  end
end
