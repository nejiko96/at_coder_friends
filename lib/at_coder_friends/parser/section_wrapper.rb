# frozen_string_literal: true

module AtCoderFriends
  module Parser
    # holds a section of problrem page
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
          siblings.reduce('') { |m, node| m + node.content }.gsub("\r\n", "\n")
        end
      end

      def html
        @html ||= begin
          siblings.reduce('') { |m, node| m + node.to_html }.gsub("\r\n", "\n")
        end
      end

      def find_element(tags)
        elem = nil
        siblings.any? do |node|
          tags.any? do |tag|
            elem = node.name == tag ? node : node.search(tag)[0]
          end
        end
        elem
      end

      def code_block_content
        @code_block_content ||= code_block(:content)
      end

      def code_block_html
        @code_block_html ||= code_block(:to_html)
      end

      def code_block(mtd)
        elem = find_element(%w[pre blockquote])
        elem && elem.send(mtd).lstrip.gsub("\r\n", "\n") || ''
      end
    end
  end
end
