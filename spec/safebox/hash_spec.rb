describe Safebox::Hash do
  subject(:hash) { Safebox::Hash.new("password") }
  let(:secret) { "batman is a sissy" }

  describe "#fetch" do
    it "returns the decrypted value if it exists" do
      hash[:secret] = secret

      expect(hash.fetch(:secret)).to eq(secret)
      expect(hash.fetch(:secret, "not the secret")).to eq(secret)
      expect(hash.fetch(:secret) { raise "I should not be called" }).to eq(secret)
    end

    it "returns the default value if key does not exist and default was given" do
      expect(hash.fetch(:nonexistent, "u wot m8?")).to eq("u wot m8?")
    end

    it "yields if key does not exist and default was given" do
      expect(hash.fetch(:nonexistent) { |key| "#{key}: u wot m8?" }).to eq("nonexistent: u wot m8?")
    end

    it "raises an error if both default and block was given" do
      expect { hash.fetch(:nonexistent, "default") { "block" } }
        .to raise_error(ArgumentError, "give default value or default block, not both")
    end

    it "raises an error if key does not exist and no default given" do
      expect { hash.fetch(:nonexistent) }.to raise_error(KeyError, "key not found: :nonexistent")
    end
  end

  describe "#[]" do
    it "returns the decrypted value if it exists" do
      hash[:secret] = secret
      expect(hash[:secret]).to eq(secret)
    end

    it "returns nil if the key does not exist" do
      expect(hash[:nonexistent]).to be_nil
    end
  end

  describe "#[]=" do
    it "encrypts and sets the key value" do
      hash[:secret] = secret
      expect(hash.data.fetch(:secret)).not_to eq(secret)
    end
  end

  describe "#each" do
    let(:copy) { {} }

    before do
      hash[:secret] = secret
      hash[:extra] = "penguin roolz!"
    end

    it "yields each key and decrypted value in the hash" do
      hash.each { |key, value| copy[key] = value }
      expect(copy).to eq(secret: secret, extra: "penguin roolz!")
    end

    it "returns an enumerator if no block given" do
      enumerator = hash.each
      expect(enumerator).to be_a(Enumerator)

      enumerator.each { |key, value| copy[key] = value }
      expect(copy).to eq(secret: secret, extra: "penguin roolz!")
    end
  end
end
