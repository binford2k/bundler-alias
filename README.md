# Bundler Alias

This [bundler plugin](https://bundler.io/guides/bundler_plugins.html) allows you
to select between multiple more or less equivalent gem implementations without
requiring upstream accommodations. This is useful, for example, when a defunct
project is forked to keep it alive, but the ecosystem hasn't caught up and
updated all the dependencies yet.

## Use Case

This was initially developed to aid in testing Puppet modules after the
[OSS Puppet rug pull](https://overlookinfratech.com/2024/11/08/sequestered-source/).
The testing framework is all Ruby based, so the first step in testing any Puppet
module is, you guessed it, `bundle install`.

Updating your own `Gemfile` is pretty straightforward. And when using ModuleSync
it's not too difficult to [push that change out to all your modules](https://github.com/voxpupuli/modulesync_config/commit/bcae6e8382f121ea4d1146901051cb9cce7f11ae).

But what about when you depend on a gem like `puppet-strings` that has a transitive
dependency on `puppet`? You'll end up with both `openvox` and `puppet` installed.
In this particular case, it's (probably) ok because glob order finds `openvox` first.
But what if you want to test your module against both implementations or you're not
lucky enough to have a lexicographically ordered name?

That's actually not possible to do in a reasonable manner without this plugin.

> [!IMPORTANT]
> [See below](#required-bundler-version) for important information if you're attempting
> to alias a directly declared gem without modifying the `Gemfile`.


## Usage

First install the plugin:

```
$ bundle plugin install "bundler-alias"
```

Then configure your alias(es):

```
$ bundle config set aliases 'puppet:openvox'
```

And then `bundle install` and  run your tests as usual. Any gem that requires `puppet`
will be transparently rewritten to depend on `openvox` instead. Now your tests will
actually test what you expect them to be testing.

### Alias specification

The specification for aliases is a comma separated list of colon separated aliases.
This means `"source:target,source2:target2,source3:target3"` and so on.

### Global installation

If you so choose, you can install and configure the plugin globally so that all
projects will rewrite dependencies transparently. Be forewarned that this will
affect every `bundle install` command you run.

```
$ cd ~ # ensure you're in your home directory
$ bundle plugin install "bundler-alias"
$ bundle config set --global aliases 'puppet:openvox'
```

### Version matching

If a `Gemfile` specifies a gem version constraint that is not valid for the
aliased gem then the installation will fail because the gem cannot be found. In
this case, the recommended approach is to contribute a fix upstream to the
original author. There is likely a reason why they specified that constraint.

If this is not feasible for some reason, then you may consider using
[`bundler-inject`](https://github.com/tarnowsc/bundler-override) to modify
the dependencies and constraint specifications.

## Limitations

This alias is not smart. It doesn't know anything about version numbers, or breaking
changes or really anything except the name of gems. This means that when there are
actual major breaking changes, this trivial rewriting of gem names will not be
sufficient and code written for one gem will break on the other. In the case of
*testing* that is acceptable because it means that tests break and surface the
need for code updates. But if you're using this to band-aid over dependencies in
production, be aware that it's a very thin and fragile veneer.

### Required Bundler version

There are four ways that this plugin will alias gems and their dependencies.

1. During `bundle install`:
    1. it will alias gems directly declared in your `Gemfile`.
    2. it will alias the dependencies of those gems as they're resolved.
2. During `bundle exec $cmd` (and other commands):
    1. it will alias gems directly declared in your `Gemfile`.
    2. it will alias the dependencies of those gems as they're resolved.

The plugin hook providing the functionality for method `2.1` above is in
[an unmerged pull request](https://github.com/ruby/rubygems/pull/6961) on the Bundler project.
If you need this functionality, for example when testing a `puppetlabs` Puppet module
on OpenVox with an unchanged `Gemfile`, then you'll need to build and install this
specific version of Bundler.

```
$ git clone --depth 1 -b bundler-plugin-eval-hooks https://github.com/ccutrer/rubygems.git
    Cloning into 'rubygems'...
    remote: Enumerating objects: 4349, done.
    remote: Counting objects: 100% (4349/4349), done.
    remote: Compressing objects: 100% (2722/2722), done.
    remote: Total 4349 (delta 973), reused 3122 (delta 812), pack-reused 0 (from 0)
    Receiving objects: 100% (4349/4349), 13.47 MiB | 7.09 MiB/s, done.
    Resolving deltas: 100% (973/973), done.
$ cd rubygems/bundler
$ gem build bundler.gemspec
    Successfully built RubyGem
    Name: bundler
    Version: 2.6.0.dev
    File: bundler-2.6.0.dev.gem
$ gem install ./bundler-2.6.0.dev.gem
    Successfully installed bundler-2.6.0.dev
    1 gem installed
```

If a `Gemfile.lock` exists, then you'll need to update it to reference the Bundler
version you just installed before proceeding with installing and using gems.

```
$ bundle update --bundler=2.6.0.dev
```

## Credit

This plugin takes a lot of inspiration, and even borrows a bit of code, from the
[`bundler-inject`](https://github.com/tarnowsc/bundler-override) project.
