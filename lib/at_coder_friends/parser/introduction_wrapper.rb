# frozen_string_literal: true

module AtCoderFriends
  module Parser
    # holds introduction of problrem page
    class IntroductionWrapper
      attr_reader :div

      def initialize(div)
        @div = div
      end

      def intro
        @intro ||= begin
          div2 = div.dup
          extract_intro(div2)
          div2
        end
      end

      def extract_intro(node)
        found = false
        node.children.each do |cld|
          found = true if %w[h2 h3].any? { |h| cld.name == h }
          if found
            cld.remove
          else
            found = extract_intro(cld)
          end
        end
        found
      end

      def html
        @html ||= intro.to_html.gsub("\r\n", "\n")
      end
    end
  end
end
