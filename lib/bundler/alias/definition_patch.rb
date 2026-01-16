module Bundler
  module Alias
    module DefinitionPatch
      def self.included(base)
        base.class_eval do

          class << self
            alias_method :build_alias, :build

            def build(gemfile, lockfile, unlock)
              override_dependencies(build_alias(gemfile, lockfile, unlock)) || self
            end

            def override_dependencies(definition)
              definition.dependencies.each do |d|
                next unless Bundler::Alias.aliases.include? d.name

                warn "Gem dependency #{d.name} has been aliased to #{Bundler::Alias.aliases[d.name]}."
                d.name = Bundler::Alias.aliases[d.name]
              end
              definition
            end
          end

        end
      end
    end
  end
end

module Bundler
  class Definition
    include Alias::DefinitionPatch
  end
end
