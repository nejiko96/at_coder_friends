# frozen_string_literal: true

StubRequest = Struct.new(:method, :path, :query, :body) do
  BASE_URL = 'https://beta.atcoder.jp/'

  def initialize(method, path, query = nil, body = '')
    super(method, path, query, body)
  end

  def mock
    file = (method == :get ? path : "#{path}_done")
    file = File.expand_path("../mocks/#{file}.html", __dir__)
    File.read(file, encoding: Encoding::UTF_8)
  end

  def url_for(contest)
    ret = path == 'login' ? BASE_URL : File.join(BASE_URL, 'contests', contest)
    ret = File.join(ret, path)
    ret += "?#{query}" if query
    ret
  end
end

REQS = [
  StubRequest.new(:get, 'login'),
  StubRequest.new(:get, 'tasks'),
  StubRequest.new(:get, 'tasks/practice_1'),
  StubRequest.new(:get, 'tasks/practice_2'),
  StubRequest.new(:get, 'submit'),
  StubRequest.new(
    :post, 'login', nil,
    username: 'foo',
    password: 'bar',
    csrf_token: '2yXslAOpndNWTpYmjqZ7C+JAT3pWB4zz90FYWkwcs7I='
  ),
  StubRequest.new(
    :post, 'submit', nil,
    'data.TaskScreenName': 'practice_1',
    'data.LanguageId': '3024',
    csrf_token: '2yXslAOpndNWTpYmjqZ7C+JAT3pWB4zz90FYWkwcs7I=',
    # rubocop:disable Layout/EmptyLinesAroundArguments
    sourceCode:
      <<~SRC
        a = gets.to_i
        b, c = gets.split.map(&:to_i)
        s = gets.chomp

        puts "\#{a + b + c} \#{s}"
      SRC
    # rubocop:enable Layout/EmptyLinesAroundArguments
  )
].freeze
CONTESTS = %w[practice arc001].freeze

shared_context :atcoder_stub do
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
end
