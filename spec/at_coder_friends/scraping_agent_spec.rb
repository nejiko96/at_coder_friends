# frozen_string_literal: true

StubRequest = Struct.new(:method, :path, :query, :body) do
  URL_FMT = 'http://%<contest>s.contest.atcoder.jp/'

  def initialize(method, path, query = nil, body = '')
    super(method, path, query, body)
  end

  def mock
    file = (method == :get ? path : "#{path}_done")
    file = File.expand_path("../mocks/#{file}.html", __dir__)
    File.read(file, encoding: Encoding::UTF_8)
  end

  def url_for(contest)
    ret = format(URL_FMT, contest: contest)
    ret += path
    ret += "?#{query}" if query
    ret
  end
end

CONTESTS = %w[practice arc001].freeze
REQS = [
  StubRequest.new(:get, 'login'),
  StubRequest.new(:get, 'assignments'),
  StubRequest.new(:get, 'tasks/practice_1'),
  StubRequest.new(:get, 'tasks/practice_2'),
  StubRequest.new(:get, 'submit'),
  StubRequest.new(
    :post, 'login', nil,
    name: 'abc', password: 'xyz'
  ),
  StubRequest.new(
    :post, 'submit', 'task_id=207',
    __session: 'f3c011467c2a8db6242e48e3eea35eac',
    task_id: '207',
    language_id_207: '3024',
    language_id_2520: '3003',
    # rubocop:disable Layout/EmptyLinesAroundArguments
    source_code:
      <<~SRC
        a = gets.to_i
        b, c = gets.split.map(&:to_i)
        s = gets.chomp

        puts "\#{a + b + c} \#{s}"
      SRC
    # rubocop:enable Layout/EmptyLinesAroundArguments
  )
].freeze

RSpec.describe AtCoderFriends::ScrapingAgent do
  include_context :atcoder_env

  subject(:agent) { described_class.new(contest, config) }
  let(:contest) { 'arc001' }
  let(:config) { { 'user' => 'abc', 'password' => 'xyz' } }

  before :each do
    CONTESTS.each do |contest|
      REQS.each do |req|
        stub_request(req.method, req.url_for(contest))
          .with(body: req.body)
          .to_return(
            status: 200,
            headers: { content_type: 'text/html' },
            body: req.mock
          )
      end
    end
  end

  describe '#fetch_all' do
    subject { agent.fetch_all }

    context 'from ARC#001' do
      it 'fetches problems' do
        expect(subject.size).to eq(2)
      end
    end

    context 'from practice' do
      let(:contest) { 'practice' }

      it 'fetches problems' do
        expect(subject.size).to eq(2)
      end
    end
  end

  describe '#submit' do
    subject { agent.submit(File.join(contest_root, prg)) }
    let(:prg) { 'A.rb' }

    it 'posts the source' do
      expect(subject).to be_a(Mechanize::Page)
    end
  end
end
