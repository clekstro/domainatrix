module Domainatrix
  class HostToHash
    def initialize(parts, suffixes)
      @parts = parts
      @suffixes = suffixes
      @public_suffix = []
      @domain = ""
      @subdomains = []
    end

    def convert
      sub_hash = @suffixes

      @parts.each_with_index do |part, i|
        sub_hash = sub_parts = sub_hash[part] || {}
        process_with_wildcards(part, i) and break if sub_parts.has_key? "*"
        process_with_empties(part, i) and break if sub_parts.empty? || !sub_parts.has_key?(@parts[i+1])
        @public_suffix << part
      end

      domain_hash
    end

    private

    def process_with_empties(part, i)
      @public_suffix << part
      @domain = @parts[i+1]
      @subdomains = @parts.slice(i+2, @parts.size) || []
    end

    def process_with_wildcards(part, i)
      @public_suffix << part
      @public_suffix << @parts[i+1]
      @domain = @parts[i+2]
      @subdomains = @parts.slice(i+3, @parts.size) || []
    end

    def domain_hash
      {:public_suffix => @public_suffix.reverse.join("."),
       :domain => @domain,
       :subdomain => @subdomains.reverse.join(".")}
    end
  end
end
