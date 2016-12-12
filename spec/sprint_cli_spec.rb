require 'spec_helper'

describe Terjira::SprintCLI do
  let(:prompt) { TTY::TestPrompt.new }
  let(:boards) { MockResource.boards }
  let(:scrum_boards) { boards.select { |b| b.type == 'scrum' } }
  let(:kanban_boards) { boards.select { |b| b.type == 'kanban' } }
  let(:sprints) { MockResource.sprints }
  let(:issues) { MockResource.issues }

  before :each do
    allow(TTY::Prompt).to receive(:new).and_return(prompt)
  end

  context '#list' do
    it 'presents sprints' do
      allow(Terjira::Client::Board).to receive(:all).and_return(scrum_boards)
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
  end

  context '#show' do
    it 'presents the sprint with issues' do
      sprint = sprints.first
      allow(Terjira::Client::Sprint).to receive(:find).and_return(sprint)
      allow(Terjira::Client::Issue).to receive(:all).and_return(issues)

      result = capture(:stdout) { described_class.start %w(show 32) }

      expect(result).to be_include sprint.id.to_s
      expect(result).to be_include sprint.name
      expect(result).to be_include sprint.goal
      issues.each do |issue|
        expect(result).to be_include issue.key
        expect(result).to be_include issue.summary
      end
    end
  end

  context '#active' do
    it 'presents active sprints with issues' do
      board = boards.first
      allow(Terjira::Client::Sprint).to receive(:find_active).with(board.id).and_return(sprints)
      allow(Terjira::Client::Issue).to receive(:all).and_return(issues)

      result = capture(:stdout) do
        described_class.start ['active', '--board', board.id]
      end

      sprints.each do |sprint|
        expect(result).to be_include sprint.id.to_s
        expect(result).to be_include sprint.name
        expect(result).to be_include sprint.goal
      end
      issues.each do |issue|
        expect(result).to be_include issue.key
        expect(result).to be_include issue.summary
      end
    end
  end
end
