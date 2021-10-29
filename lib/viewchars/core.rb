require 'tty/table'

module Viewchars
  class CLI
    def basex2dec(n)
      base = case @opts[:base].to_sym
        when :bin then 2
        when :oct then 8
        when :dec then return n.to_i
        when :hex then 16
        else print_usage
      end
      n.to_s.to_i(base)
    end

    def encode_with(i, encoding)
      begin
        i.chr(encoding)
      rescue
        '-'
      end
    end

    def utf8_reencode(ch)
      begin
        ch.encode(Encoding::UTF_8)
      rescue
        '-'
      end
    end

    def unicode_name(ch)
      begin
        Unicode::Name.of(ch).split(' ').map(&:capitalize).join(' ')
      rescue
        nil
      end
    end

    def dec2code(n)
      "U+#{n.to_s(16).rjust(4,'0')}".upcase
    end
    
    def build_info_list(codepoints, encoding)
      info = []
      codepoints.each do |n|
        n_dec = basex2dec(n.downcase.gsub(/([\da-f]+)/, '\1'))
        ch = encode_with(n_dec, encoding)
        ch_utf8 = utf8_reencode(ch)
        code = dec2code(n_dec)
        name = unicode_name(ch)
        unless name
          ch = ch_utf8 = '-'
          name = '(not a Unicode codepoint)' 
        end
        info << [ch, ch_utf8, n, code, name]
      end
      info
    end

    def prepare_output(lists)
      lists.each do |encoding,info|
        # -c|--codes and/or -n|--names
        # -t|--tabular (default)
        _ch      = encoding
        _ch_utf8 = 'Forced'
        _n       = @opts[:base].capitalize
        _code    = 'Code'
        _name    = 'Name'
        header = []
        rows = []
        if @opts[:tabular]
          header = [_ch, _ch_utf8, _n, _code, _name]
          rows = info
        else
          header = nil
          rows = info.map do |e|
            r = [e.first] if @opts[:codes]
            r = [e.last] if @opts[:names]
            r = [e.first, e.last] if @opts[:codes] and @opts[:names]
            r
          end
        end
        table = TTY::Table.new(header, rows)
        puts TTY::Table::Renderer::Basic.new(table).render
      end
    end

    def chars2codepoints(chars)
      @opts[:base] ||= 'dec'
      codepoints = @opts.arguments.join(' ').codepoints.map(&:to_s)
      info_lists = @requested_encodings.map{|e| [e, build_info_list(codepoints, e)]}.to_h
      prepare_output(info_lists)
    end

    def codepoints2chars(codepoints)
      @opts[:base] ||= 'hex'
      info_lists = @requested_encodings.map{|e| [e, build_info_list(codepoints, e)]}.to_h
      prepare_output(info_lists)
    end
  end
end
