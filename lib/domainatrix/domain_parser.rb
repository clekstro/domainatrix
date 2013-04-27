module Domainatrix
  class DomainParser
    include Addressable

    attr_reader :public_suffixes

    def initialize(file_name)
      @public_suffixes = {}
      process_dat_file(file_name)
    end

    def parse(url)
      return {} unless url && url.strip != ''
      uri_hash_for(url)
    end

    private

    def uri_hash_for(url)
      url = "http://#{url}" unless url[/:\/\//]
      uri = URI.parse(url)
      path = path_for(uri)

      set_hash_parameters(uri, path, url)
    end

    def set_hash_parameters(uri, path, url)
      uri_hash = uri.host == 'localhost' ? localhost_hash : parse_domains_from_host(uri.host || uri.basename)

      uri_hash.merge({
        :scheme => uri.scheme,
        :host   => uri.host,
        :path   => path,
        :url    => url
      })
    end

    def localhost_hash
      { :public_suffix => '', :domain => 'localhost', :subdomain => '' }
    end

    def parse_domains_from_host(host)
      return {} unless host
      HostToHash.new(dissect(host), @public_suffixes).convert
    end

    def dissect(host)
      host.split(".").reverse
    end

    def path_for(uri)
      uri.query ? "#{uri.path}?#{uri.query}" : uri.path
    end

    def process_dat_file(file_name)
      dat_file = FileOpener.open(file_name)
      dat_file.each_line do |line|
        process_line(line)
      end
    end

    def process_line(line)
      line = line.strip
      unless (line =~ /\/\//) || line.empty?
        extract_parts_from(line)
      end
    end

    def extract_parts_from(line)
      parts = line.split(".").reverse

      sub_hash = @public_suffixes
      parts.each do |part|
        sub_hash = (sub_hash[part] ||= {})
      end
    end

  end
end
