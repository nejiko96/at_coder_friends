# frozen_string_literal: true

require_relative 'regression'

module AtCoderFriends
  # tasks for regression
  module Regression
    module_function

    def section_list
      list = local_pbm_list.flat_map do |contest, q, url|
        page = agent.get(url)
        %w[h2 h3].flat_map do |tag|
          page.search(tag).map do |h|
            { contest: contest, q: q, text: normalize(h.content) }
          end
        end
      end
      list.group_by { |sec| sec[:text] }.each do |k, vs|
        puts [k, vs.size, vs[0][:contest], vs[0][:q]].join("\t")
      end
    end

    def normalize(s)
      s
        .tr('　０-９Ａ-Ｚａ-ｚ', ' 0-9A-Za-z')
        .gsub(/[^一-龠_ぁ-ん_ァ-ヶーa-zA-Z0-9 ]/, '')
        .gsub(/\d+/, '{N}')
        .gsub(' ', '')
        .downcase
        .strip
    end
  end
end

namespace :regression do
  desc 'list all section titles'
  task :section_list do
    AtCoderFriends::Regression.section_list
  end
end
