require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

unless ENV['RS_PROVISION'] == 'no'
  run_puppet_install_helper
  hosts.each do |host|
    puppet_version = (on default, puppet('--version')).output.chomp

    if ENV['PUPPET_INSTALL_TYPE'] == 'pe' && Gem::Version.new(puppet_version) < Gem::Version.new('4.0.0')
      on host, puppet('resource package hocon provider=pe_gem')
    elsif Gem::Version.new(puppet_version) >= Gem::Version.new('4.0.0')
      on host, puppet('resource package hocon provider=puppet_gem')
    else
      on host, puppet('resource package hocon provider=gem')
    end
  end
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    hosts.each do |host|
      if host['platform'] !~ /windows/i
        copy_root_module_to(host, :source => proj_root, :module_name => 'hocon')
      end
    end
    hosts.each do |host|
      if host['platform'] =~ /windows/i
        on host, puppet('plugin download')
      end
    end
  end

  c.treat_symbols_as_metadata_keys_with_true_values = true
end
