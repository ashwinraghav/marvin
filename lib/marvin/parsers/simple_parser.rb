module Marvin
  module Parsers
    class SimpleParser < Marvin::AbstractParser
      
      private
      
      # Parses an incoming message by using string
      # Manipulation.
      def self.parse!(line)
        prefix_text = nil
        prefix_text, line = line.split(" ", 2) if line[0] == ?:
        command = Command.new("#{line}\r\n")
        command.prefix = self.extract_prefix(prefix_text)
        parts = Marvin::Util.arguments(line)
        command.code = parts.shift
        command.params = parts
        return command
      end
      
      # From a given string, attempts to get the correct
      # type of prefix (be it a HostMask or a Server name).
      def self.extract_prefix(prefix_text)
        return if prefix_text.blank?
        prefix_text = prefix_text[1..-1] # Remove the leading :
        # I think I just vomitted in my mouth a little...
        if prefix_text =~ /^([A-Za-z0-9\-\[\]\\\`\^\|\{\}\_]+)(\!\~?([^@]+))?(@(.*))?$/
          prefix = Prefixes::HostMask.new($1, $3, $5)
        else
          prefix = Prefixes::Server.new(prefix_text.strip)
        end
        return prefix
      end
    end 
  end
end