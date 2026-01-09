require "bundler/alias/version"
require "bundler/friendly_errors.rb"

module Bundler
  module Alias
    class << self
      attr_reader :aliases

      def register
        return if defined?(@registered) && @registered
        @registered = true

        @aliases = Hash[Bundler.settings[:aliases].split(',').map {|i| i.split ':' } ]

        Bundler::Plugin.add_hook('before-install-all') do |deps|
          require "bundler/alias/dependency_patch"
          deps.each do |d|
            next unless Bundler::Alias.aliases.include? d.name

            puts "Gemfile declared #{d.name}, but it has been aliased to #{Bundler::Alias.aliases[d.name]}."
            d.name = Bundler::Alias.aliases[d.name]
          end
        end

      end
    end
  end
end
