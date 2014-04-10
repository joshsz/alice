module Alice

  module Util
    
    class Sanitizer

      def self.process(text)
        text ||= ""
        text.gsub!(/ the the /i, " the ")
        text.gsub!(/ the ye /i, " ye ")
        text.gsub!(/ the a /i, " the ")
        text.gsub!(/ a the /i, " a ")
        text.gsub!(/ a a /i, " a ")
        text.gsub!(/ a ye /i, " ye ")
        text.gsub!(/ ye ye /i, " ye ")
        text.gsub!(/ ye a /i, " ye ")
        text.gsub!(/ an a /i, " a ")
        text.gsub!(/ a a/i, " an a")
        text.gsub!(/ a e/i, " an e")
        text.gsub!(/ a i/i, " an i")
        text.gsub!(/ a o/i, " an o")
        text.gsub!(/^am/i, 'is')
        text.gsub!('..', '.')
        text.gsub!('!.', '!')
        text.gsub!('. .', '.')
        text.gsub!('  ', ' ')
        text.gsub!(' " ', ' "')
        text.gsub!(/ (A) /) {|s| s.downcase}
        text.gsub!(/ (The) /) {|s| s.downcase}
        text.gsub!(/ (An) /) {|s| s.downcase}
        text.gsub!(/ (Their) /) {|s| s.downcase}
        text.gsub!(/^ /, '')
        text
      end

      def self.initial_upcase(text)
        text.gsub(/^([a-z])/) {|s| s.upcase}
      end

      def self.initial_downcase(text)
        text.gsub(/^([A-Z])/) {|s| s.downcase}
      end

      def self.strip_pronouns(text)
        text.gsub!(/^I /i, '')
        text
      end

      def self.make_third_person(text)
        text.gsub!(/ I /i, ' they ')
        text.gsub!(/ me /i, ' they ')
        text
      end

      def self.ordinal(number)
        number == 1 && "1st" || number == 2 && "2nd" || number == 3 && "3rd" || "#{number}th"
      end

    end

  end

end