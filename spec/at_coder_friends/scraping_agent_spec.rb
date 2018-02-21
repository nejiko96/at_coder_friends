# frozen_string_literal: true

RSpec.describe AtCoderFriends::ScrapingAgent do
  include_context :atcoder_env

  subject(:agent) { described_class.new(contest, config) }
  let(:contest) { 'arc001' }
  let(:config) do
    {
      user:     'user',
      password: 'password'
    }
  end

  BASE_URL = 'http://arc001.contest.atcoder.jp/'
  PATHS = [
    [:get,  'login'],
    [:post, 'login', 'login_done'],
    [:get,  'assignments'],
    [:get,  'tasks/practice_1'],
    [:get,  'tasks/practice_2'],
    [:get,  'submit'],
    [:post, 'submit?task_id=207', 'submit_done']
  ].freeze

  before :each do
    PATHS.each do |method, path, file|
      file ||= path
      mock = File.expand_path("../mocks/#{file}.html", __dir__)
      stub_request(method, "#{BASE_URL}#{path}").to_return(
        status: 200,
        headers: { content_type: 'text/html' },
        body: File.read(mock, encoding: Encoding::UTF_8)
      )
    end
  end

  describe '#fetch_all' do
    subject { agent.fetch_all }

    it 'fetches problems' do
      expect(subject).not_to be_nil
    end
  end

  describe '#submit' do
    subject { agent.submit(File.join(contest_root, prog)) }
    let(:prog) { 'A.rb' }

    it 'submits src' do
      expect(subject).not_to be_nil
    end
  end
end
