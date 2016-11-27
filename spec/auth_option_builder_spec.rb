require 'spec_helper'
require 'terjira/client/auth_option_builder'

describe Terjira::Client::AuthOptionBuilder do

  class TestClass
    extend Terjira::Client::AuthOptionBuilder
  end

  let(:prompt) { TTY::TestPrompt.new }
  let(:auth_options) { { site: "https://localhost",
                         context_path: "jira",
                         username: "orwell",
                         password: "10930725",
                         auth_type: :basic} }
  let(:inputs) { auth_options.values.join("\r") }

  before :each do
    allow(TTY::Prompt).to receive(:new).and_return(prompt)
  end

  it 'must be cached' do
    prompt.input << inputs
    prompt.input.rewind
    capture(:stdout) do
      TestClass.build_auth_options("testauthpath")
      result = TestClass.build_auth_options_by_cached("testauthpath")
      expect(result).to eq(auth_options)
    end
  end

  it 'must expire cached option' do
    prompt.input << inputs
    prompt.input.rewind
    capture(:stdout) do
      TestClass.build_auth_options("testauthpath")
      TestClass.expire_auth_options("testauthpath")
      result = TestClass.build_auth_options_by_cached("testauthpath")
      expect(result).to eq(nil)
    end
  end

  it 'must get auth info by tty' do
    prompt.input << inputs
    prompt.input.rewind
    capture(:stdout) do
      result = TestClass.build_auth_options_by_tty
      expect(result).to eq(auth_options)
    end
  end
end
