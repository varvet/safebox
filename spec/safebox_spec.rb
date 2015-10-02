describe Safebox do
  it "has a version number" do
    expect(Safebox::VERSION).not_to be nil
  end

  it "can encrypt and decrypt" do
    password = "super secret password"
    message = "Elvis lives!!!"

    expect(Safebox.decrypt(password, Safebox.encrypt(password, message))).to eq(message)
  end

  it "raises an error when decrypting a box with the wrong version" do
    ciphertext = [1337, "smaller salt in this version", "this is the ciphertext"].pack("Q<a*a*")

    expect {
      Safebox.decrypt("password", ciphertext)
    }.to raise_error(ArgumentError, "bad box version 1337")
  end
end
