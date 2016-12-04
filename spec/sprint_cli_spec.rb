require 'spec_helper'

describe Terjira::SprintCLI do

  let(:prompt) { TTY::TestPrompt.new }
  let(:boards) { MockResource.boards }
  let(:sprints) { MockResource.sprints }
  let(:issues) { MockResource.issues }

  before :each do
    allow(TTY::Prompt).to receive(:new).and_return(prompt)
  end

  context "#list" do
    it 'must show sprints' do
      allow(Terjira::Client::Board).to receive(:all).and_return(boards.select { |b| b.type == 'scrum' })
      allow(Terjira::Client::Sprint).to receive(:all).and_return(sprints)

      prompt.input << "\r"
      prompt.input.rewind

      result = capture(:stdout) { described_class.start([:list]) }

      sprints.each do |sprint|
        expect(result).to be_include sprint.id.to_s
        expect(result).to be_include sprint.name
        expect(result).to be_include sprint.goal
      end
    end

    it 'must show warning when select kanban board' do
      allow(Terjira::Client::Board).to receive(:all).and_return(boards.select { |b| b.type == 'kanban' })

      prompt.input << "\r"
      prompt.input.rewind

      result = capture(:stdout) { described_class.start([:list]) }

      expect(result).to be_include "not support"
    end
  end

  context '#show' do
    it 'must sprint with issues' do
      sprint = sprints.first
      allow(Terjira::Client::Sprint).to receive(:find).and_return(sprint)
      allow(Terjira::Client::Issue).to receive(:all).and_return(issues)

      result = capture(:stdout) { described_class.start %w[show 32] }

      expect(result).to be_include sprint.id.to_s
      expect(result).to be_include sprint.name
      expect(result).to be_include sprint.goal
      issues.each do |issue|
        expect(result).to be_include issue.key
        expect(result).to be_include issue.summary
      end
    end
  end
end
