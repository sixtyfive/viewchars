# frozen_string_literal: true

require_relative 'viewchars/version'
require_relative 'viewchars/core'

require 'slop'         # gem install slop
require 'colorize'     # gem install colorize
require 'unicode/name' # gem install unicode-name
require 'pp'

module Viewchars
  class Error < StandardError; end

  class CLI
    def print_usage
      warn "Usage: #{File.basename(__FILE__)} [options] <arg1> <arg2> <...>"
      warn ""
      warn "  where arguments depend on direction: strings for 'reverse', numbers for 'forward'"
      warn "  and where options may be:"
      warn ""
      warn "  -l|--list-encodings: do nothing except list all known encodings"
      warn ""
      warn "  -d|--direction: <reverse|forward> chars to codepoints (default) or vice versa"
      warn ""
      warn "  -e|--encoding <comma separated list | all> (default: utf-8)"
      warn "  -b|--base <bin|oct|dec|hex> (default: numbers are interpreted as hexadecimals)"
      warn ""
      warn "  -t|--tabular: output codepoints in input base and base 10, requested-encoding, forced utf8, and name (default)"
      warn "  -c|--codes: output each char's code point as a hex number (can be combined with -n)"
      warn "  -n|--names: if applicable, show the Unicode Character Name for each codepoint (can be combined with -c)"
      warn ""
      exit
    end

    def list_known_encodings
      @known_encodings.each{|k,v| puts k}
    end

    def initialize
      begin
        @opts = Slop.parse do |o|
          o.bool   '-l', '--list-encodings', ''
          o.string '-e', '--encoding',       ''
          o.string '-b', '--base',           ''
          o.bool   '-c', '--codes',          ''
          o.bool   '-n', '--names',          ''
          o.bool   '-t', '--tabular',        ''
          o.string '-d', '--direction',      ''
        end
      rescue Slop::UnknownOption, Slop::MissingArgument, Slop::MissingRequiredOption
        print_usage
      end

      @opts[:direction] ||= 'reverse'
      @opts[:encoding] ||= 'UTF-8'
      @opts[:tabular] = true if !(@opts[:codes] || @opts[:names])

      @known_encodings = Encoding.list.map{|e| [e.to_s.downcase, e.to_s]}.to_h.sort.to_h
      @requested_encodings = []
      @opts[:encoding].split(',').each do |encoding|
        (@requested_encodings = @known_encodings.values; break) if encoding == 'all'
        if @known_encodings[encoding.downcase]
          @requested_encodings << @known_encodings[encoding.downcase]
        else
          warn "Error: No such encoding: #{encoding}"
          exit
        end
      end

      if @opts[:list_encodings]
        list_known_encodings
        exit
      else
        print_usage unless @opts.arguments.any?
        case @opts[:direction]
          when 'reverse' then
            chars = @opts.arguments.join(' ').chars
            chars2codepoints(chars)
          when 'forward' then
            codepoints = @opts.arguments
            codepoints2chars(codepoints)
        end
      end
    end

    def self.start; new; end
  end
end
