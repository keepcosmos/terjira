require 'spec_helper'

module Terjira
  class TestCLI < Thor
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

    subject.build_options!

    expect(projects).to include(subject.options["project"])
  end

  it 'suggest board selections' do
    allow(Terjira::Client::Board).to receive(:all).and_return(boards)

    subject.options = {"board" => "board"}
    prompt.input << "\r"
    prompt.input.rewind

    subject.build_options!
    expect(boards).to include(subject.options["board"])
  end

  it 'suggeset sprint selections' do
    allow(Terjira::Client::Board).to receive(:all).and_return(boards)

    allow(Terjira::Client::Sprint).to receive(:all).and_return(sprints)

    prompt.input << "\r\r"
    prompt.input.rewind

    subject.options = { "sprint" => "sprint" }
    subject.build_options!

    expect(sprints).to include(subject.options["sprint"])
    expect(boards).to include(subject.options["board"])
  end
end
