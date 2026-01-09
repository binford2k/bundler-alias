module Bundler
  module Alias
    module DependencyPatch
      def self.included(base)
        base.class_eval do
          alias_method :dependencies_alias, :dependencies
          alias_method :runtime_dependencies_alias, :runtime_dependencies if base.method_defined?(:runtime_dependencies)

          def dependencies
            override_dependencies(dependencies_alias) || []
          end

          def runtime_dependencies
            override_dependencies(runtime_dependencies_alias) || []
          end

          def override_dependencies(deps)
            deps.each do |d|
              next unless Bundler::Alias.aliases.include? d.name

              puts "Gem dependency #{d.name} has been aliased to #{Bundler::Alias.aliases[d.name]}."
              d.name = Bundler::Alias.aliases[d.name]
            end
            deps
          end
        end
      end
    end
  end
end

module Bundler
  class RemoteSpecification
    include Alias::DependencyPatch
  end

  class EndpointSpecification
    include Alias::DependencyPatch
  end
end

module Gem
  class Specification
    include Bundler::Alias::DependencyPatch
  end
end
