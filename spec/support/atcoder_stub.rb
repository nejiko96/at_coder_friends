# frozen_string_literal: true

StubRequest = Struct.new(:method, :path, :query, :body) do
  BASE_URL = 'https://atcoder.jp/'

  def initialize(method, path, query = nil, body = '')
    super(method, path, query, body)
  end

  def mock
    file = (method == :get ? path : "#{path}_done")
    file = File.expand_path("../mocks/#{file}.html", __dir__)
    File.read(file, encoding: Encoding::UTF_8)
  end

  def url
    ret = File.join(BASE_URL, path)
    ret += "?#{query}" if query
    ret
  end
end

REQS = [
  StubRequest.new(:get, 'login'),
  StubRequest.new(
    :post, 'login', nil,
    username: 'foo',
    password: 'bar',
    csrf_token: '2yXslAOpndNWTpYmjqZ7C+JAT3pWB4zz90FYWkwcs7I='
  ),
  StubRequest.new(:get, 'contests/practice/tasks'),
  StubRequest.new(:get, 'contests/practice/tasks/practice_1'),
  StubRequest.new(:get, 'contests/practice/tasks/practice_2'),
  StubRequest.new(:get, 'contests/arc001/tasks'),
  StubRequest.new(:get, 'contests/arc001/tasks/arc001_1'),
  StubRequest.new(:get, 'contests/arc001/tasks/arc001_2'),
  StubRequest.new(:get, 'contests/arc001/tasks/arc001_3'),
  StubRequest.new(:get, 'contests/arc001/tasks/arc001_4'),
  StubRequest.new(:get, 'contests/arc001/submit'),
  StubRequest.new(
    :post, 'contests/arc001/submit', nil,
    'data.TaskScreenName': 'arc001_1',
    'data.LanguageId': '3024',
    csrf_token: 'ZD8/jxTUFqgfOUYq0Y+/m7AygPqElU6UEV7nvp1mgEg=',
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

shared_context :atcoder_stub do
  before :each do
    REQS.each do |req|
      stub_request(req.method, req.url)
        .with(body: req.body)
        .to_return(
          status: 200,
          headers: { content_type: 'text/html' },
          body: req.mock
        )
    end
  end
end
