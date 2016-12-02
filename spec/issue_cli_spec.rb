require 'spec_helper'

describe Terjira::IssueCLI do

  let(:prompt) { TTY::TestPrompt.new }
  let(:boards) { MockResource.boards }
  let(:sprints) { MockResource.sprints }
  let(:issues) { MockResource.issues }

  before :each do
    allow(TTY::Prompt).to receive(:new).and_return(prompt)
  end

  it 'must show issue' do
    issue = issues.first
    allow(Terjira::Client::Issue).to receive(:find).and_return(issue)

    result = capture(:stdout) { described_class.start(%[show]) }

    puts result
  end
end
