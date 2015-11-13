require "tempfile"
require "tmpdir"
require "safebox/cli"

describe Safebox::CLI do
  def dump(safebox)
    safebox = Safebox::File.new(cli.file)
    safebox.write(Safebox::Hash.new(password).update(safebox))
  end

  let(:cli) do
    Safebox::CLI.new({
      file: @tempfile,
      password: password,
    })
  end

  describe "safebox" do
    describe "list" do
      it "prints nothing when empty" do
        expect { cli.run("list") }.not_to output.to_stdout
      end

      it "will not create the safe.box if it does not exist", tempfile: :directory do
        expect {
          cli.run("list")
        }.not_to change { File.exist?("safe.box") }.from(false)
      end
    end

    describe "get" do
      it "fails with a warning and exit status 1 if key does not exist" do
        expect(Kernel).to receive(:abort).with("no such key: password")
        cli.run("get", "password")
      end

      it "prints the value of the given key" do
        cli.run("set", "password=hunter2")

        expect { cli.run("get", "password") }.to output("hunter2").to_stdout
      end

      it "appends a newline if stdout is a tty" do
        cli.run("set", "password=hunter2")

        expect {
          expect($stdout).to receive(:tty?).and_return(true)
          cli.run("get", "password")
        }.to output("hunter2\n").to_stdout
      end

      it "will not create the safe.box if it does not exist", tempfile: :directory do
        expect(Kernel).to receive(:abort).with(any_args)

        expect {
          cli.run("get", "password")
        }.not_to change { File.exist?("safe.box") }.from(false)
      end
    end

    describe "set" do
      it "sets a key in a new safebox" do
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

      it "sets an existing key in a safebox" do
        expect { cli.run("list") }.not_to output.to_stdout

        cli.run("set", "username=Arne Anka")
        expect { cli.run("list") }.to output(/username=Arne Anka/).to_stdout

        cli.run("set", "username=Anna Anka")
        expect { cli.run("list") }.not_to output(/Arne Anka/).to_stdout
        expect { cli.run("list") }.to output(/username=Anna Anka/).to_stdout
      end

      it "sets multiple keys in the safebox" do
        expect { cli.run("list") }.not_to output.to_stdout

        cli.run("set", "username=Arne Anka", "password=hunter2")
        expect { cli.run("list") }.to output(/username=Arne Anka/).to_stdout
        expect { cli.run("list") }.to output(/password=hunter2/).to_stdout
      end

      it "will create the safe.box if it does not exist", tempfile: :directory do
        expect {
          cli.run("set", "password=hunter2")
        }.to change { File.exist?("safe.box") }.from(false).to(true)
      end
    end

    describe "delete" do
      it "deletes a key from the safebox" do
        cli.run("set", "username=Arne")

        cli.run("delete", "username")
        expect { cli.run("list") }.not_to output.to_stdout
      end

      it "deletes a key from the safebox" do
        cli.run("set", "username=Arne", "password=hunter2")

        cli.run("delete", "password")
        expect { cli.run("list") }.to output(/username/).to_stdout
        expect { cli.run("list") }.not_to output(/password/).to_stdout
      end

      it "will not create the safe.box if it does not exist", tempfile: :directory do
        expect {
          cli.run("delete", "password")
        }.not_to change { File.exist?("safe.box") }.from(false)
      end
    end
  end

  it "re-encrypts the safebox if it is an old version" do

  end
end
