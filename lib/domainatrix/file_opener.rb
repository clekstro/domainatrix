module Domainatrix
  module FileOpener
    def self.open(file_name)
      # If we're in 1.9, make sure we're opening it in UTF-8
      if RUBY_VERSION >= '1.9'
        dat_file = File.open(file_name, "r:UTF-8")
      else
        dat_file = File.open(file_name)
      end
    end
  end
end
