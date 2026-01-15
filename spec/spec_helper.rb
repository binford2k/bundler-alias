require "bundler/setup"
require "colorize"

require "bundler-alias"

Dir[File.join(__dir__, "support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include Spec::Helpers

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.before(:suite) do
    # Bundler uses git to install the plugin, so changes must be committed so the tests are accurate.
    if `git status lib --porcelain`.length != 0
      raise "You cannot run specs with uncommitted changes to the lib directory."
    end
    puts "Detected bundler versions: #{Spec::Helpers.bundler_versions.join(", ")}".light_yellow
    puts "Using bundler #{Spec::Helpers.bundler_version}".light_yellow
  end

  config.after do
    rm_test_dir
  end
end
