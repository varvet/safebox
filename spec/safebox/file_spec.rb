describe Safebox::File do
  subject(:file) { Safebox::File.new(@tempfile) }

  def dump(data)
    File.write(@tempfile, @data, encoding: Encoding::BINARY)
  end

  describe "#read" do
    def read_version(version)
      path = File.expand_path("../old_boxes/#{version}.box", __dir__)
      expect(File.exist?(path)).to be_truthy

      called = false
      value = Safebox::File.new(path).read(password) do |*args|
        called = true
        yield *args
      end

      expect(called).to eq(block_given?)
      value
    end

    let(:expected_hash) { Safebox::Hash.new(password).update({ "secret" => "batman is a sissy" }) }

    it "can read the current version" do
      hash = read_version(Safebox::VERSION)
      expect(hash).to eq(expected_hash)
    end

    it "can read v0.1.0" do
      hash = read_version("0.1.0") { |hash, version| expect(version).to eq("0.1.0") }

      expect(hash).to eq(expected_hash)
    end
  end
end
