describe Safebox::Hash do
  subject(:hash) { Safebox::Hash.new("password") }
  describe "#fetch" do
    it "returns the decrypted value if it exists" do
      hash[:secret] = "batman is a sissy"

      expect(hash.fetch(:secret)).to eq("batman is a sissy")
      expect(hash.fetch(:secret, "not the secret")).to eq("batman is a sissy")
      expect(hash.fetch(:secret) { raise "I should not be called" }).to eq("batman is a sissy")
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
      hash[:secret] = "batman is a sissy"
      expect(hash[:secret]).to eq("batman is a sissy")
    end

    it "returns nil if the key does not exist" do
      expect(hash[:nonexistent]).to be_nil
    end
  end

  describe "#[]=" do
    it "encrypts and sets the key value" do
      hash[:secret] = "batman is a sissy"
      expect(hash.encrypted_hash.fetch(:secret)).not_to eq("batman is a sissy")
    end
  end

  describe "#each" do
    let(:copy) { {} }

    before do
      hash[:secret] = "batman is a sissy"
      hash[:extra] = "penguin roolz!"
    end

    it "yields each key and decrypted value in the hash" do
      hash.each { |key, value| copy[key] = value }
      expect(copy).to eq(secret: "batman is a sissy", extra: "penguin roolz!")
    end

    it "returns an enumerator if no block given" do
      enumerator = hash.each
      expect(enumerator).to be_a(Enumerator)

      enumerator.each { |key, value| copy[key] = value }
      expect(copy).to eq(secret: "batman is a sissy", extra: "penguin roolz!")
    end
  end

  describe "#update" do
    it "updates with another hash, overwriting duplicate keys" do
      hash[:secret] = "first secret"
      hash.update(secret: "batman is a sissy", extra: "penguin roolz!")

      expect(hash[:secret]).to eq("batman is a sissy")
      expect(hash[:extra]).to eq("penguin roolz!")
    end

    it "allows a block to handle conflicts" do
      called = false
      hash[:secret] = "first secret"
      hash.update(secret: "batman is a sissy", extra: "penguin roolz!") do |key, old_value, new_value|
        called = true
        expect(key).to eq(:secret)
        expect(old_value).to eq("first secret")
        expect(new_value).to eq("batman is a sissy")

        "batman is a penguin"
      end

      expect(called).to eq(true)
      expect(hash[:secret]).to eq("batman is a penguin")
      expect(hash[:extra]).to eq("penguin roolz!")
    end
  end

  describe "#==" do
    before { hash[:secret] = "batman is a sissy" }

    it "is true if other is a safebox hash with same passwor and same data" do
      other_hash = Safebox::Hash.new(password)
      other_hash[:secret] = "batman is a sissy"

      expect(hash).not_to eq(other_hash)
    end

    it "is false if other is a safebox hash with same password but other data" do
      other_hash = Safebox::Hash.new(password)
      other_hash[:secret] = "batman is not a sissy"

      expect(hash).not_to eq(other_hash)
    end

    it "is false if other is a safebox hash with other password but same data" do
      other_hash = Safebox::Hash.new("some other password")
      other_hash[:secret] = "batman is a sissy"

      expect(hash).not_to eq(other_hash)
    end

    it "is false if other is not a safebox hash" do
      other_hash = { secret: "batman is a sissy" }

      expect(hash).not_to eq(other_hash)
    end
  end
end
