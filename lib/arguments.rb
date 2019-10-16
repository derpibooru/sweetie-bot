# frozen_string_literal: true

class Arguments
  attr_accessor :raw, :parsed

  #
  # TODO:
  # write a proper parser >_>
  #
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
end
