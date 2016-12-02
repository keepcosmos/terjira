require 'spec_helper'

describe Terjira::SprintCLI do

  let(:prompt) { TTY::TestPrompt.new }
  let(:boards) { MockResource.boards }
  let(:sprints) { MockResource.sprints }

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
end
