require 'pathname'
require 'json'
require 'i18n'
require 'virtualbox'
require 'radar'

module Vagrant
  # TODO: Move more classes over to the autoload model. We'll
  # start small, but slowly move everything over.

  autoload :CLI,       'vagrant/cli'
  autoload :Config,    'vagrant/config'
  autoload :DataStore, 'vagrant/data_store'
  autoload :Errors,    'vagrant/errors'
  autoload :Util,      'vagrant/util'

  module Command
    autoload :Base,      'vagrant/command/base'
    autoload :GroupBase, 'vagrant/command/group_base'
    autoload :Helpers,   'vagrant/command/helpers'
    autoload :NamedBase, 'vagrant/command/named_base'
  end

  # The source root is the path to the root directory of
  # the Vagrant gem.
  def self.source_root
    @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
  end
end

# Setup Radar application for exception catching
Radar::Application.new(:vagrant) do |app|
  app.reject :class, Vagrant::Errors::VagrantError
  app.reject :class, SystemExit
  app.reporters.use :file
  app.rescue_at_exit!
end

# Default I18n to load the en locale
I18n.load_path << File.expand_path("templates/locales/en.yml", Vagrant.source_root)

# Load them up. One day we'll convert this to autoloads. Today
# is not that day. Low hanging fruit for anyone wishing to do it.
libdir = File.expand_path("lib/vagrant", Vagrant.source_root)
Vagrant::Util::GlobLoader.glob_require(libdir, %w{
  downloaders/base provisioners/base provisioners/chef systems/base
  hosts/base})

# Initialize the built-in actions
Vagrant::Action.builtin!
