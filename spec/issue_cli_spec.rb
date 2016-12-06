require 'spec_helper'

describe Terjira::IssueCLI do

  let(:prompt) { TTY::TestPrompt.new }
  let(:boards) { MockResource.boards }
  let(:sprints) { MockResource.sprints }
  let(:issues) { MockResource.issues }

  before :each do
    allow(TTY::Screen).to receive(:width).and_return(10 ** 4)
    allow(TTY::Prompt).to receive(:new).and_return(prompt)
  end

  context "#show" do
    it 'must show issue' do
      issue = issues.first
      allow(Terjira::Client::Issue).to receive(:find).and_return(issue)

      result = capture(:stdout) { described_class.start(%w[show ISSUE-KEY]) }

      expect(result).to be_include(issue.key)
      expect(result).to be_include(issue.summary)
      expect(result).to be_include(issue.priority.name)
      expect(result).to be_include(issue.issuetype.name)
      expect(result).to be_include(issue.status.name)
      expect(result).to be_include(issue.assignee.name)
      expect(result).to be_include(issue.reporter.name)
    end

    it 'must show help with no arg' do
      result = capture(:stdout) { described_class.start(%w[show]) }
      expect(result).to be_include("Commands:")
    end
  end

  context "#list" do
    it 'must show issue list' do
      allow(Terjira::Client::Issue).to receive(:all).and_return(issues)

      result = capture(:stdout) { described_class.start(%w[list]) }
      issues.each do |issue|
        expect(issue)
      end
    end
  end
end
