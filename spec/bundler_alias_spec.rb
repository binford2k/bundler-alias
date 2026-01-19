require 'spec_helper'
RSpec.describe Bundler::Alias do
  let(:project_root) { Pathname.new(__dir__).join("..").expand_path.to_s }

  def verify_installation
    expect(out).to include("Fetching #{project_root}")
    expect(out).to include "Using bundler-alias #{Bundler::Alias::VERSION}"
  end


  context "on installation of the plugin" do
    before do
      sanitize_test_dir
    end

    it "installs the plugin using: bundle plugin install" do
      bundle("plugin install bundler-alias --git #{project_root}")

      verify_installation
    end

    it "installs the plugin using: bundle plugin install verbose" do
      bundle("plugin install bundler-alias --git #{project_root}", verbose: true)

      verify_installation
    end
  end

  context "no aliased gems in gemfile" do
    before do
      sanitize_test_dir
      write_gemfile
      bundle("plugin install bundler-alias --git #{project_root}")
    end

    it "with no aliased gems configured" do
      Bundler.settings.set_global(:aliases, nil)
      bundle(:install)

      expect(lockfile_specs).not_to include("openvox")
      expect(lockfile_specs).not_to include("puppet")
    end

    it "with empty set of aliased gems" do
      Bundler.settings.set_global(:aliases, [])
      bundle(:install)

      expect(lockfile_specs).not_to include("openvox")
      expect(lockfile_specs).not_to include("puppet")
    end

    it "with puppet gem aliased" do
      Bundler.settings.set_global(:aliases, "puppet:openvox")
      bundle(:install)

      expect(lockfile_specs).not_to include("openvox")
      expect(lockfile_specs).not_to include("puppet")
    end
  end

  context "aliased gems" do
    before do
      sanitize_test_dir
      bundle("plugin install bundler-alias --git #{project_root}")
    end

    it "without aliases configured" do
      Bundler.settings.set_global(:aliases, nil)
      write_gemfile("gem 'puppet', '8.10.0'\ngem 'puppet-strings', '5.0.0'")

      if RUBY_VERSION.split('.').first == 4
        bundle(:install, expect_error: true)
        expect(err).to include "Bundler::SolveFailure: Could not find compatible versions"
      else
        bundle(:install)
        expect(lockfile_spec_names).not_to include("openvox")
        expect(lockfile_specs).to include(["puppet", "8.10.0"])
      end
    end

    it "in declared gem" do
      Bundler.settings.set_global(:aliases, "puppet:openvox")
      write_gemfile("gem 'puppet'")

      bundle(:install)
      expect(lockfile_spec_names).to include("openvox")
      expect(lockfile_spec_names).not_to include("puppet")
    end

    it "in declared gem with bad version" do
      Bundler.settings.set_global(:aliases, "puppet:openvox")
      write_gemfile("gem 'puppet', '8.10.0'")

      bundle(:install, expect_error: true)
      expect(err).to include "Could not find gem 'openvox (= 8.10.0)'"
    end

    it "in gem dependency" do
      Bundler.settings.set_global(:aliases, "puppet:openvox")
      write_gemfile("gem 'puppet-strings'")

      bundle(:install)
      expect(lockfile_spec_names).to include("openvox")
      expect(lockfile_spec_names).to include("openfact")
      expect(lockfile_spec_names).not_to include("puppet")
      expect(lockfile_dep_names_for_spec("puppet-strings")).to include('openvox')
    end
  end

end
