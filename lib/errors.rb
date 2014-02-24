module Errors
  class MissingHeaders      < StandardError; end
  class TokenFailed         < StandardError; end
  class InvalidAutoshipItem < StandardError; end
  class InvalidAutoship     < StandardError; end
  class InvalidAddress      < StandardError; end
end
