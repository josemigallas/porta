FactoryBot.define do
  factory(:proxy) do
    association :service
    api_backend { 'http://api.example.net:80' }
    secret_token { "123" }
    policies_config { [{name: 'cors', version: '0.0.1', configuration: {foo: 'bar'}}] }
  end

  factory(:proxy_rule) do
    http_method { "GET" }
    delta { 1 }
    sequence(:created_at) { |n| Time.zone.now - n.days }
    sequence(:pattern) { |n| "/foo/bar/#{n}" }
    association :metric
    association :proxy
  end

  factory(:proxy_config) do
    content { ({ proxy: { hosts: ['example.com']}}.to_json) }
    environment { 'sandbox' }
    association :proxy
  end
end
