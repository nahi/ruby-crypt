module OpenSSL
  module PKey
    class RSA
      def _dump(lv)
        self.to_pem
      end

      def self._load(str)
        new(str)
      end
    end
  end
end
