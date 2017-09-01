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
  let(:resource_store) { Terjira::ResourceStore.instance }

  let(:prompt) { TTY::TestPrompt.new }

  %w(projects boards sprints statuses users priorities resolutions).each do |resource|
    let(resource) { MockResource.send(resource) }
  end

  before :each do
    allow(TTY::Prompt).to receive(:new).and_return(prompt)
    resource_store.clear
  end

  context '#select' do
    before :each do
      prompt.input << "\r"
      prompt.input.rewind
    end

    it 'suggests proejcts' do
      allow(Terjira::Client::Project).to receive(:all).and_return(projects)

      subject.options = { 'project' => 'project' }
      subject.suggest_options

      expect(resource_store).to be_exists(:project)
    end

    it 'suggests boards' do
      allow(Terjira::Client::Board).to receive(:all).and_return(boards)

      subject.options = { 'board' => 'board' }
      subject.suggest_options

      expect(resource_store).to be_exists(:board)
    end

    it 'suggeset sprints' do
      allow(Terjira::Client::Sprint).to receive(:all).and_return(sprints)

      subject.options = { 'sprint' => 'sprint' }
      subject.suggest_options(resources: { board: boards.first })

      expect(resource_store).to be_exists(:sprint)
    end

    it 'suggests assignees' do
      allow(Terjira::Client::User).to receive(:fetch_assignables).and_return(users)

      subject.options = { 'assignee' => 'assignee' }
      subject.suggest_options(resources: { project: projects.first })

      expect(resource_store).to be_exists(:assignee)
    end

    it 'suggests statuses' do
      allow(Terjira::Client::Status).to receive(:all).and_return(statuses)

      subject.options = { 'status' => 'status' }
      subject.suggest_options(resources: { project: projects.first })

      expect(resource_store).to be_exists(:status)
    end

    it 'suggests issuetypes' do
      subject.options = { 'issuetype' => 'issuetype' }
      subject.suggest_options(resources: { project: projects.first })

      expect(resource_store).to be_exists(:issuetype)
    end

    it 'suggests priority' do
      allow(Terjira::Client::Priority).to receive(:all).and_return(priorities)

      subject.options = { 'priority' => 'priority' }
      subject.suggest_options

      expect(resource_store).to be_exists(:priority)
    end

    it 'suggests resolution' do
      allow(Terjira::Client::Resolution).to receive(:all).and_return(resolutions)

      subject.options = { 'resolution' => 'resolution' }
      subject.suggest_options

      expect(resource_store).to be_exists(:resolution)
    end
  end

  it 'opens summary ask prompt' do
    prompt.input << "test summary\r"
    prompt.input.rewind

    subject.options = { 'summary' => 'summary' }

    subject.suggest_options

    expect(resource_store.get(:summary)).to be == 'test summary'
  end

  it 'opens comment ask prompt' do
    prompt.input << "multiline\ncomment"
    prompt.input.rewind

    subject.options = { 'comment' => 'comment' }

    subject.suggest_options

    expect(resource_store.get(:comment)).to be == "multiline\ncomment"
  end

  it 'opens default editor for comment' do
    stub_const('ENV', 'EDITOR' => 'vim')
    expect_any_instance_of(Object).to receive(:system).and_return(true)
    expect(File).to receive(:read).and_return("editor\ncomment")

    subject.options = { 'comment' => 'comment', :editor => true }

    subject.suggest_options

    expect(resource_store.get(:comment)).to be == "editor\ncomment"
  end

  it 'opens description ask prompt' do
    prompt.input << "multiline\ndescription"
    prompt.input.rewind

    subject.options = { 'description' => 'description' }

    subject.suggest_options

    expect(resource_store.get(:description)).to be == "multiline\ndescription"
  end

  it 'opens default editor for description' do
    stub_const('ENV', 'EDITOR' => 'vim')
    expect_any_instance_of(Object).to receive(:system).and_return(true)
    expect(File).to receive(:read).and_return("editor\ndescription")

    subject.options = { 'description' => 'description', :editor => true }

    subject.suggest_options

    expect(resource_store.get(:description)).to be == "editor\ndescription"
  end

  it 'raises an error if there is no default editor' do
    stub_const('ENV', 'EDITOR' => nil)
    subject.options = { 'description' => 'description', :editor => true }

    expect { subject.suggest_options }
      .to raise_error('EDITOR environment variable not found. Please set a default editor.')
  end

  it 'raises an error if editor returns a non-zero exit code' do
    stub_const('ENV', 'EDITOR' => 'vim')
    expect_any_instance_of(Object).to receive(:system).and_return(false)

    subject.options = { 'description' => 'description', :editor => true }

    expect { subject.suggest_options }
      .to raise_error('Editor returned a non-zero exit code. Something must have gone wrong')
  end
end
