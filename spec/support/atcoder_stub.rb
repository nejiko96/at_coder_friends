# frozen_string_literal: true

require 'cgi'

StubRequest = Struct.new(:method, :path, :param, :result) do
  BASE_URL = 'https://atcoder.jp/'

  def initialize(method, path, result: nil, **param)
    super(method, path, param, result)
  end

  def url
    ret = File.join(BASE_URL, path)
    ret += "?#{query}" if query
    ret = Regexp.new(Regexp.escape(ret).gsub('@', '.*')) if ret.include?('@')
    ret
  end

  def query
    return nil unless method == :get && param && !param.empty?

    param.map { |k, v| "#{k}=#{v}" }.join('&')
  end

  def body
    method == :post ? param : ''
  end

  def register(result = nil)
    sr = WebMock.stub_request(method, url)
    sr = sr.with(body: body) if method == :post
    sr.to_return stub_response(result)
  end

  def stub_response(result)
    if path.start_with?('login')
      login_response
    else
      other_response(result)
    end
  end

  def login_response
    if method == :get
      # always show login form
      requested_page(result)
    elsif param && param[:username] == 'foo' && param[:password] == 'bar'
      # authentication success => redirect to requested page
      proc do |request|
        redirect_to(request.uri.query_values['continue'])
          .tap do |h|
            h[:headers][:set_cookie] = 'SessionKey=4b12f708b5a219ec; Path=/;'
          end
      end
    else
      # authentication fail => show login form again
      proc { |request| redirect_to(request.uri) }
    end
  end

  def other_response(result)
    proc do |request|
      if request.headers['Cookie']&.include?('SessionKey=4b12f708b5a219ec')
        # valid session => show requested page
        requested_page(result)
      elsif request.uri.path.start_with?('/contests/practice/tasks')
        # invalid session and require entry => return 404
        not_found
      elsif request.uri.path.include?('/tasks')
        # authentication not required
        requested_page(result)
      else
        # invalid session => show login form
        redirect_to('/login?continue=' + CGI.escape(request.uri.to_s))
      end
    end
  end

  def redirect_to(location)
    {
      status: 302,
      headers: { location: location }
    }
  end

  def requested_page(result)
    {
      status: 200,
      headers: { content_type: content_type },
      body: mock(result)
    }
  end

  def not_found
    {
      status: 404,
      headers: { content_type: 'text/html' },
      body: mock_page('404')
    }
  end

  def content_type
    path.end_with?('/json') ? 'application/json' : 'text/html'
  end

  def mock(result)
    pat = result || self.result
    mock_path = path
    mock_path += "_#{pat}" if pat && !pat.empty?
    mock_path += '_done' if method == :post
    mock_page(mock_path)
  end

  def mock_page(path)
    File.new(File.expand_path("../mocks/#{path}.html", __dir__))
  end
end

REQS = [
  StubRequest.new(
    :get, 'login',
    continue: '@'
  ),
  StubRequest.new(
    :post, 'login?continue=@',
    username: 'foo',
    password: 'bar',
    csrf_token: 'ZD8/jxTUFqgfOUYq0Y+/m7AygPqElU6UEV7nvp1mgEg='
  ),
  StubRequest.new(
    :post, 'login?continue=@',
    username: 'hoge',
    password: 'piyo',
    csrf_token: 'ZD8/jxTUFqgfOUYq0Y+/m7AygPqElU6UEV7nvp1mgEg='
  ),
  StubRequest.new(:get, 'contests/practice/tasks'),
  StubRequest.new(:get, 'contests/practice/tasks/practice_1'),
  StubRequest.new(:get, 'contests/practice/tasks/practice_2'),
  StubRequest.new(:get, 'contests/practice/submit'),
  StubRequest.new(
    :post, 'contests/practice/submit',
    'data.TaskScreenName': 'practice_1',
    'data.LanguageId': '3024',
    csrf_token: 'ZD8/jxTUFqgfOUYq0Y+/m7AygPqElU6UEV7nvp1mgEg=',
    sourceCode:
      <<~SRC
        a = gets.to_i
        b, c = gets.split.map(&:to_i)
        s = gets.chomp

        puts "\#{a + b + c} \#{s}"
      SRC
  ),
  StubRequest.new(:get, 'contests/practice/custom_test'),
  StubRequest.new(
    :post, 'contests/practice/custom_test/submit/json',
    'data.LanguageId': '3023',
    csrf_token: 'ZD8/jxTUFqgfOUYq0Y+/m7AygPqElU6UEV7nvp1mgEg=',
    sourceCode: (
      <<~SRC
        # -*- coding: utf-8 -*-
        a = int(input())
        b, c = map(int, input().split())
        s = input()
        print("{} {}".format(a+b+c, s))
      SRC
    ),
    input:
      <<~DATA
        1
        2 3
        test
      DATA
  ),
  StubRequest.new(
    :post, 'contests/practice/custom_test/submit/json',
    'data.LanguageId': '3023',
    csrf_token: 'ZD8/jxTUFqgfOUYq0Y+/m7AygPqElU6UEV7nvp1mgEg=',
    sourceCode: (
      <<~SRC
        # -*- coding: utf-8 -*-
        a = int(input())
        b, c = map(int, input().split())
        s = input()
        print(ans)
      SRC
    ),
    input:
      <<~DATA
        1
        2 3
        test
      DATA
  ),
  StubRequest.new(
    :post, 'contests/practice/custom_test/submit/json',
    'data.LanguageId': '3023',
    csrf_token: 'ZD8/jxTUFqgfOUYq0Y+/m7AygPqElU6UEV7nvp1mgEg=',
    sourceCode: (
      <<~SRC
        # -*- coding: utf-8 -*-
        a = int(input())
        b, c = map(int, input().split())
        s = input()
        print("{}_{}".format(a+b+c, s))
      SRC
    ),
    input:
      <<~DATA
        1
        2 3
        test
      DATA
  ),
  StubRequest.new(
    :post, 'contests/practice/custom_test/submit/json',
    result: 'ERROR',
    'data.LanguageId': '0000',
    csrf_token: 'ZD8/jxTUFqgfOUYq0Y+/m7AygPqElU6UEV7nvp1mgEg=',
    sourceCode: (
      <<~SRC
        # -*- coding: utf-8 -*-
        a = int(input())
        b, c = map(int, input().split())
        s = input()
        print("{} {}".format(a+b+c, s))
      SRC
    ),
    input:
      <<~DATA
        1
        2 3
        test
      DATA
  ),
  StubRequest.new(
    :post, 'contests/practice/custom_test/submit/json',
    'data.LanguageId': '3023',
    csrf_token: 'ZD8/jxTUFqgfOUYq0Y+/m7AygPqElU6UEV7nvp1mgEg=',
    sourceCode: (
      <<~SRC
        # -*- coding: utf-8 -*-
        a = int(input())
        b, c = map(int, input().split())
        s = input()
        print("{} {}".format(a+b+c, s))
      SRC
    ),
    input:
      <<~DATA
        72
        128 256
        myonmyon
      DATA
  ),
  StubRequest.new(:get, 'contests/arc001/tasks'),
  StubRequest.new(:get, 'contests/arc001/tasks/arc001_1'),
  StubRequest.new(:get, 'contests/arc001/tasks/arc001_2'),
  StubRequest.new(:get, 'contests/arc001/tasks/arc001_3'),
  StubRequest.new(:get, 'contests/arc001/tasks/arc001_4'),
  StubRequest.new(:get, 'contests/arc002/tasks/arc002_1'),
  StubRequest.new(:get, 'contests/abc003/tasks/abc003_4'),
  StubRequest.new(:get, 'contests/tdpc/tasks'),
  StubRequest.new(:get, 'contests/tdpc/tasks/tdpc_contest')
].freeze

TEST_RESULT_REQ = StubRequest.new(
  :get, 'contests/practice/custom_test/json',
  reload: 'true'
)

shared_context :atcoder_stub do
  let(:test_result) { 'OK' }

  before :each do
    REQS.each(&:register)
    TEST_RESULT_REQ.register(test_result)
  end
end
