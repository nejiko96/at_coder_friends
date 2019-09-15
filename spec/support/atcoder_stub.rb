# frozen_string_literal: true

StubRequest = Struct.new(:method, :path, :param, :result) do
  BASE_URL = 'https://atcoder.jp/'

  def initialize(method, path, result: nil, **param)
    super(method, path, param, result)
  end

  def mock_path(result)
    pat = result || self.result
    ret = path
    ret += "_#{pat}" if pat && !pat.empty?
    ret += '_done' if method == :post
    ret
  end

  def mock(result)
    file = File.expand_path("../mocks/#{mock_path(result)}.html", __dir__)
    File.read(file, encoding: Encoding::UTF_8)
  end

  def url
    ret = File.join(BASE_URL, path)
    ret += "?#{query}" if query
    ret
  end

  def query
    return nil unless method == :get && param

    param.map { |k, v| "#{k}=#{v}" }.join('&')
  end

  def body
    method == :post ? param : nil
  end

  def register(result = nil)
    WebMock
      .stub_request(method, url)
      .with(body: body || '')
      .to_return(
        status: 200,
        headers: { content_type: 'text/html' },
        body: mock(result)
      )
  end
end

REQS = [
  StubRequest.new(:get, 'login'),
  StubRequest.new(
    :post, 'login',
    username: 'foo',
    password: 'bar',
    csrf_token: '2yXslAOpndNWTpYmjqZ7C+JAT3pWB4zz90FYWkwcs7I='
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
        # 整数の入力
        a = int(input())
        # スペース区切りの整数の入力
        b, c = map(int, input().split())
        # 文字列の入力
        s = input()
        # 出力
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
        # 整数の入力
        a = int(input())
        # スペース区切りの整数の入力
        b, c = map(int, input().split())
        # 文字列の入力
        s = input()
        # 出力
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
        # 整数の入力
        a = int(input())
        # スペース区切りの整数の入力
        b, c = map(int, input().split())
        # 文字列の入力
        s = input()
        # 出力
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
        # 整数の入力
        a = int(input())
        # スペース区切りの整数の入力
        b, c = map(int, input().split())
        # 文字列の入力
        s = input()
        # 出力
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
  StubRequest.new(:get, 'contests/arc001/tasks'),
  StubRequest.new(:get, 'contests/arc001/tasks/arc001_1'),
  StubRequest.new(:get, 'contests/arc001/tasks/arc001_2'),
  StubRequest.new(:get, 'contests/arc001/tasks/arc001_3'),
  StubRequest.new(:get, 'contests/arc001/tasks/arc001_4'),
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
