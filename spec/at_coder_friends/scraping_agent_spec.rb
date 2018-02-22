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

    # TODO yield test
    context 'from ARC#001' do
      it 'fetches problems' do
        expect { subject }.to output(
          <<~TEXT
            ***** fetch_all arc001 *****
            fetch list from http://arc001.contest.atcoder.jp/assignments ...
            fetch problem from /tasks/practice_1 ...
            fetch problem from /tasks/practice_2 ...
          TEXT
        ).to_stdout
        expect(subject.size).to eq(2)
        expect(subject[0]).to have_attributes(q: 'A')
        expect(subject[1]).to have_attributes(q: 'B')
      end
    end

    context 'from practice' do
      let(:contest) { 'practice' }

      it 'fetches problems' do
        expect { subject }.to output(
          <<~TEXT
            ***** fetch_all practice *****
            fetch list from http://practice.contest.atcoder.jp/assignments ...
            fetch problem from /tasks/practice_1 ...
            fetch problem from /tasks/practice_2 ...
          TEXT
        ).to_stdout
        expect(subject.size).to eq(2)
        expect(subject[0]).to have_attributes(q: 'A')
        expect(subject[1]).to have_attributes(q: 'B')
      end
    end
  end

  describe '#submit' do
    subject { agent.submit(File.join(contest_root, prg)) }

    context 'when there is no error' do
      let(:prg) { 'A.rb' }

      it 'posts the source' do
        expect { subject }.to \
          output("***** submit A.rb *****\n").to_stdout
        expect(subject).to be_a(Mechanize::Page)
      end
    end

    context 'for alt version' do
      let(:prg) { 'A_v2.rb' }

      it 'posts the source' do
        expect { subject }.to \
          output("***** submit A_v2.rb *****\n").to_stdout
        expect(subject).to be_a(Mechanize::Page)
      end
    end

    context 'for unsupported extention' do
      let(:prg) { 'A.py' }

      it 'show error' do
        expect { subject }.to \
          raise_error(AtCoderFriends::AppError, '.py is not available.')
      end
    end

    context 'for non-existent problem' do
      let(:prg) { 'C.rb' }

      it 'show error' do
        expect { subject }.to \
          raise_error(AtCoderFriends::AppError, 'problem C not found.')
      end
    end
  end
end
