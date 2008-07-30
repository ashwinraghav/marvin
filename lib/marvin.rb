$:.unshift File.dirname(__FILE__) # Append the current working dir to the front of the line.

require 'rubygems'
require 'active_support'
require 'marvin/core_ext'

# Make all exceptions available
require 'marvin/exceptions'

module Marvin
  autoload :Base,        'marvin/base'
  autoload :ClientMixin, 'marvin/client_mixin'
  autoload :Settings,    'marvin/settings'
  autoload :Logger,      'marvin/logger'
  autoload :IRC,         'marvin/irc'
  
  # Default Handlers
  autoload :CommandHandler, 'marvin/command_handler'
  
  Settings.setup # Load Settings etc.
  
end