require 'thor'

module Vagrant
  # Entrypoint for the Vagrant CLI. This class should never be
  # initialized directly (like a typical Thor class). Instead,
  # use {Environment#cli} to invoke the CLI.
  class CLI < Thor
    # Registers the given class with the CLI so it can be accessed.
    # The class must be a subclass of either {Command} or {GroupCommand}.
    def self.register(klass, name, usage, description, opts=nil)
      opts ||= {}

      if klass <= Command::GroupBase
        # A subclass of GroupBase is a subcommand, since it contains
        # many smaller commands within it.
        desc usage, description, opts
        subcommand name, klass
      elsif klass <= Command::Base
        # A subclass of Base is a single command, since it
        # is invoked as a whole (as Thor::Group)
        desc usage, description, opts
        define_method(name) { |*args| invoke klass, args }
      end

      if opts[:alias]
        # Alises are defined for this command, so properly alias the
        # newly defined method/subcommand:
        map opts[:alias] => name
      end
    end
  end
end
