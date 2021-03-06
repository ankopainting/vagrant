require 'fileutils'

module Vagrant
  module Command
    class UpgradeTo060Command < Base
      desc "Upgrade pre-0.6.0 environment to 0.6.0"
      register "upgrade_to_060", :hide => true

      def execute
        @env.ui.warn "vagrant.commands.upgrade_to_060.info", :_prefix => false
        @env.ui.warn "", :_translate => false, :_prefix => false
        if !@env.ui.yes? "vagrant.commands.upgrade_to_060.ask", :_prefix => false, :_color => :yellow
          @env.ui.info "vagrant.commands.upgrade_to_060.quit", :_prefix => false
          return
        end

        local_data = @env.local_data
        if !local_data.empty?
          if local_data[:active]
            @env.ui.confirm "vagrant.commands.upgrade_to_060.already_done", :_prefix => false
            return
          end

          # Backup the previous file
          @env.ui.info "vagrant.commands.upgrade_to_060.backing_up", :_prefix => false
          FileUtils.cp(local_data.file_path, "#{local_data.file_path}.bak-#{Time.now.to_i}")

          # Gather the previously set virtual machines into a single
          # active hash
          active = local_data.inject({}) do |acc, data|
            key, uuid = data
            acc[key.to_sym] = uuid
            acc
          end

          # Set the active hash to the active list and save it
          local_data.clear
          local_data[:active] = active
          local_data.commit
        end

        @env.ui.confirm "vagrant.commands.upgrade_to_060.complete", :_prefix => false
      end
    end
  end
end
