require 'spec_helper'

module Terjira
  class TestCLI < Thor
    include CommonPresenter
    include IssuePresenter
    include ProjectPresenter
    include BoardPresenter
    include SprintPresenter

    include OptionSupportable
  end
end

describe Terjira::OptionSupportable do

  subject { Terjira::TestCLI.new }
  let(:prompt) { TTY::TestPrompt.new }
  let(:projects) { MockResource.projects }
  let(:boards)  { MockResource.projects }
  let(:sprints) { MockResource.sprints }

  before :each do
    allow(TTY::Prompt).to receive(:new).and_return(prompt)
  end

  it "suggest proejct selections" do
    allow(Terjira::Client::Project).to receive(:all).and_return(projects)

    subject.options = {"project" => "project"}
    prompt.input << "\r"
    prompt.input.rewind

    suggested = subject.suggest_options

    expect(projects).to include(suggested["project"])
  end

  it 'suggest board selections' do
    allow(Terjira::Client::Board).to receive(:all).and_return(boards)

    subject.options = {"board" => "board"}
    prompt.input << "\r"
    prompt.input.rewind

    suggested = subject.suggest_options
    expect(boards).to include(suggested["board"])
  end

  it 'suggeset sprint selections' do
    allow(Terjira::Client::Board).to receive(:all).and_return(boards)
    allow(Terjira::Client::Sprint).to receive(:all).and_return(sprints)

    prompt.input << "\r" * 2
    prompt.input.rewind

    subject.options = { "sprint" => "sprint" }
    suggested = subject.suggest_options(required: ["board"])
    expect(sprints).to include(suggested["sprint"])
    expect(boards).to include(suggested["board"])
  end
end
