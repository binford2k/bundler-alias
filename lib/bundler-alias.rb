require "bundler/alias/version"
#require "bundler/alias/definition_patch"
require "bundler/alias/dependency_patch"

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

        # The existence of this hook tricks Bundler's plugin system into loading our code.
        Bundler::Plugin.add_hook('before-install-all') do |deps|
# This form works on unpatched Bundler, but the hook is only invoked during `bundle install`.
# That means that it will properly munge dependencies while creating the lockfile and installing gems,
# but it will *not* affect `bundle exec` or other forms and execution fails.
# Yes, TIL that `bundle exec` evaluates the Gemfile as well as Gemfile.lock.
          deps.each do |d|
            next unless Bundler::Alias.aliases.include? d.name
            warn "Gemfile declared #{d.name}, but it has been aliased to #{Bundler::Alias.aliases[d.name]}."
            d.name = Bundler::Alias.aliases[d.name]
          end
        end

        # this hook is added by https://github.com/ruby/rubygems/pull/6961
        # Because it's invoked directly after the Gemfile is evaluated, we can munge dependencies
        # before anything else operates on it.
        Bundler::Plugin.add_hook('after-eval') do |definition|
          definition.dependencies.each do |d|
            next unless Bundler::Alias.aliases.include? d.name
            warn "Gemfile declared #{d.name}, but it has been aliased to #{Bundler::Alias.aliases[d.name]}."
            d.name = Bundler::Alias.aliases[d.name]
          end
        end

      end
    end
  end
end
