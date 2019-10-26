# frozen_string_literal: true

require_relative 'regression'

module AtCoderFriends
  # tasks for regression
  module Regression
    module_function

    SectionInfo = Struct.new(:contest, :q, :title)

    def section_list
      list = load_section_list
      save_section_list(list)
    end

    def load_section_list
      local_pbm_list.flat_map do |contest, q, url|
        page = agent.get(url)
        %w[h2 h3].flat_map do |tag|
          page.search(tag).map do |h|
            SectionInfo.new(contest, q, normalize(h.content))
          end
        end
      end
    end

    def save_section_list(list)
      File.open(log_path('section_list.txt'), 'w') do |f|
        list.group_by(&:title).each do |k, vs|
          f.puts [k, vs.size, vs[0].contest, vs[0].q].join("\t")
        end
      end
    end

    def normalize(s)
      s
        .tr('０-９Ａ-Ｚａ-ｚ', '0-9A-Za-z')
        .gsub(/[[:space:]]/, '')
        .gsub(/[^一-龠_ぁ-ん_ァ-ヶーa-zA-Z0-9 ]/, '')
        .downcase
        .gsub(/\d+/, '{N}')
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
