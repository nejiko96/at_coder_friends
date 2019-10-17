# frozen_string_literal: true

module AtCoderFriends
  module Parser
    # holds section in problrem page
    class SectionWrapper
      attr_reader :h

      def initialize(h)
        @h = h
      end

      def siblings
        @siblings ||= begin
          ret = []
          nx = h.next
          while nx && nx.name != h.name
            ret << nx
            nx = nx.next
          end
          ret
        end
      end

      def content
        @content ||= begin
          siblings.reduce('') { |m, node| m + node.content.gsub("\r\n", "\n") }
        end
      end

      def find_element(tags)
        siblings.each do |node|
          tags.each do |tag|
            elem = node.name == tag ? node : node.search(tag)[0]
            return elem if elem
          end
        end
        nil
      end

      def code_block
        @code_block ||= begin
          elem = find_element(%w[pre blockquote])
          (elem&.content || '').lstrip.gsub("\r\n", "\n")
        end
      end
    end
  end
end
