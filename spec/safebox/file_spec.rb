require "tempfile"
require "tmpdir"
require "safebox/cli"

describe Safebox::File do
  around do |example|
    case example.metadata[:tempfile]
    when :directory
      Dir.mktmpdir do |directory|
        Dir.chdir(directory) { example.run }
      end
    when false
      example.run
    else
      Tempfile.open(["safe", ".box"]) do |io|
        @tempfile = io.path
        io.unlink
        example.run
      end
    end
  end

  def dump(safebox)
    ciphertext = Safebox.encrypt(password, JSON.generate(safebox))
    File.write(@tempfile, ciphertext, encoding: Encoding::BINARY)
  end

  let(:password) { "test1234" }

  let(:file) do
    Safebox::File.new(@tempfile, password)
  end

  describe "safebox" do
    describe "data" do
      it "returns the data in the file" do
        dump({ "foo" => "bar", "quox" => "baz" })
        expect(file.data).to eq({ "foo" => "bar", "quox" => "baz" })
      end

      it "will not create the safe.box if it does not exist", tempfile: false do
        expect {
          file.data
        }.not_to change { File.exist?("safe.box") }.from(false)
      end
    end

    describe "has_key?" do
      it "returns true if the key exists" do
        dump({ "foo" => "bar", "quox" => "baz" })
        expect(file.has_key?("foo")).to be_truthy
      end

      it "returns nil if the key doesn't exist" do
        dump({ "foo" => "bar", "quox" => "baz" })
        expect(file.get("monkey")).to be_nil
        expect(file.has_key?("monkey")).to be_falsy
      end
    end

    describe "get" do
      it "returns the value of the key if it exists" do
        dump({ "foo" => "bar", "quox" => "baz" })
        expect(file.get("foo")).to eq("bar")
      end

      it "returns nil if the key doesn't exist" do
        dump({ "foo" => "bar", "quox" => "baz" })
        expect(file.get("monkey")).to be_nil
      end
    end

    describe "set" do
      it "sets a key in a new safebox" do
        file.set("foo", "123")
        expect(file.
        expect { cli.run("list") }.not_to output.to_stdout

        cli.run("set", "username=Arne Anka")
        expect { cli.run("list") }.to output(/username=Arne Anka/).to_stdout
      end

      it "sets a new key in an existing safebox" do
        expect { cli.run("list") }.not_to output.to_stdout

        cli.run("set", "username=Arne Anka")
        cli.run("set", "password=hunter2")
        expect { cli.run("list") }.to output(/username=Arne Anka/).to_stdout
        expect { cli.run("list") }.to output(/password=hunter2/).to_stdout
      end

    #   it "sets an existing key in a safebox" do
    #     expect { cli.run("list") }.not_to output.to_stdout

    #     cli.run("set", "username=Arne Anka")
    #     expect { cli.run("list") }.to output(/username=Arne Anka/).to_stdout

    #     cli.run("set", "username=Anna Anka")
    #     expect { cli.run("list") }.not_to output(/Arne Anka/).to_stdout
    #     expect { cli.run("list") }.to output(/username=Anna Anka/).to_stdout
    #   end

    #   it "sets multiple keys in the safebox" do
    #     expect { cli.run("list") }.not_to output.to_stdout

    #     cli.run("set", "username=Arne Anka", "password=hunter2")
    #     expect { cli.run("list") }.to output(/username=Arne Anka/).to_stdout
    #     expect { cli.run("list") }.to output(/password=hunter2/).to_stdout
    #   end

    #   it "will create the safe.box if it does not exist", tempfile: :directory do
    #     expect {
    #       cli.run("set", "password=hunter2")
    #     }.to change { File.exist?("safe.box") }.from(false).to(true)
    #   end
    # end

    # describe "delete" do
    #   it "deletes a key from the safebox" do
    #     cli.run("set", "username=Arne")

    #     cli.run("delete", "username")
    #     expect { cli.run("list") }.not_to output.to_stdout
    #   end

    #   it "deletes a key from the safebox" do
    #     cli.run("set", "username=Arne", "password=hunter2")

    #     cli.run("delete", "password")
    #     expect { cli.run("list") }.to output(/username/).to_stdout
    #     expect { cli.run("list") }.not_to output(/password/).to_stdout
    #   end

    #   it "will not create the safe.box if it does not exist", tempfile: :directory do
    #     expect {
    #       cli.run("delete", "password")
    #     }.not_to change { File.exist?("safe.box") }.from(false)
    #   end
    # end
  end
end
