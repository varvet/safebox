require "safebox/version"
require "safebox/file"
require "rbnacl/libsodium"

module Safebox
  BOX_VERSION = 1
  CPU_COST = 2 ** 20
  MEM_COST = 2 ** 24
  PACK_FORMAT = "Q<a32a*"

  class << self
    def encrypt(password, message)
      salt = RbNaCl::Random.random_bytes(RbNaCl::SecretBox.key_bytes)
      ciphertext = box(password, salt).encrypt(message)

      [BOX_VERSION, salt, ciphertext].pack(PACK_FORMAT)
    end

    def decrypt(password, encrypted)
      version, salt, ciphertext = encrypted.unpack(PACK_FORMAT)

      unless version == BOX_VERSION
        raise ArgumentError, "bad box version #{version.inspect}"
      end

      box(password, salt).decrypt(ciphertext)
    end

    private

    def box(password, salt)
      key = RbNaCl::PasswordHash.scrypt(password, salt, CPU_COST, MEM_COST, RbNaCl::SecretBox.key_bytes)
      RbNaCl::SimpleBox.from_secret_key(key)
    end
  end
end
