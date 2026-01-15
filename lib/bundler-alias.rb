require "bundler/alias/version"
require "bundler/friendly_errors.rb"

module Bundler
  module Alias
    class << self
      attr_reader :aliases

      def register
        return if defined?(@registered) && @registered
        @registered = true

        if Bundler.settings[:aliases] and !Bundler.settings[:aliases].empty?
          warn "Using configured aliases: #{Bundler.settings[:aliases]}"
          @aliases = Hash[Bundler.settings[:aliases].split(',').map {|i| i.split ':' } ]
        else
          @aliases = []
        end

        Bundler::Plugin.add_hook('before-install-all') do |deps|
          require "bundler/alias/dependency_patch"
          deps.each do |d|
            next unless Bundler::Alias.aliases.include? d.name

            warn "Gemfile declared #{d.name}, but it has been aliased to #{Bundler::Alias.aliases[d.name]}."
            d.name = Bundler::Alias.aliases[d.name]
          end
        end

      end
    end
  end
end
