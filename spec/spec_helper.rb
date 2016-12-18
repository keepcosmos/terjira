require 'terjira'
require_relative 'mock_resource'
require 'pry'
require 'simplecov'
SimpleCov.start

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before :example do
    Terjira::ResourceStore.instance.clear

    allow(Terjira::Client::Base).to receive(:client).and_return(JIRA::Client.new({}))

    stub_const("Terjira::FileCache::ROOT_DIR", "#{ENV['HOME']}/.testterjira")
  end

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end
end
