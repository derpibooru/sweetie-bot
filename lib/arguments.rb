# frozen_string_literal: true

# Command arguments container and parser.
# @author Luna aka Meow the Cat
# @attr [String] raw The raw, unparsed arguments string.
# @attr [Array<String>] parsed The parsed arguments string.
class Arguments
  attr_accessor :raw, :parsed

  # Parses the arguments string.
  # @todo Write a better parser. This one is pretty awful, but hey, it works.
  # @param str [String] arguments string to parse.
  # @return [Arguments, false] `self` if successful, `false` if somehow failed.
  def parse(str)
    str ||= ''

    @raw    = str
    @parsed = []

    return self if str == ''

    pieces = str.split
    buf = ''

    pieces.each do |v|
      if buf != '' || v.start_with?('"')
        buf += "#{v.gsub(/^"/, '').gsub(/"$/, '')} "

        if v.end_with?('"')
          @parsed.push buf.gsub(/\s$/, '')
          buf = ''
        end
      else
        @parsed.push v
      end
    end

    return false if buf != ''

    self
  end

  # Checks if any arguments are given.
  # @return [Boolean] `true` if at least one argument is given.
  def present?
    @raw.present?
  end
end
