require 'spec_helper'

describe Terjira::ProjectCLI do
  let(:projects) { load_response("project").map { |resp| Terjira::Client::Project.build(resp) } }

  let(:project) { Terjira::Client::Project.build(load_response("project/SAMPLEPROJECT")) }

  context "#list" do
    it 'must show project list' do
      allow(Terjira::Client::Project).to receive(:all).and_return(projects)

      result = capture(:stdout) { described_class.start(%w[ls]) }

      projects.each do |project|
        expect(result).to be_include project.key
        expect(result).to be_include project.name
        expect(result).to be_include project.projectTypeKey
      end
    end

    it 'must show empty with no project' do
      allow(Terjira::Client::Project).to receive(:all).and_return([])
      result = capture(:stdout) { described_class.start(%w[ls]) }
      expect(result).to match /nothing/i
    end
  end

  context "#show" do
    it 'must show a project by key' do
      allow(Terjira::Client::Project).to receive(:find)
        .with(project.key).and_return(project)
      allow(project).to receive(:users).and_return([])

      result = capture(:stdout) { described_class.start([:show, project.key]) }

      expect(result).to be_include project.key
      expect(result).to be_include project.name
      expect(result).to be_include project.description
    end

    it 'must suggest project if project key is not passed' do
      allow(Terjira::Client::Project).to receive(:all).and_return(projects)
      allow(Terjira::Client::Project).to receive(:find).and_return(project)
      allow(project).to receive(:users).and_return([])
      expect(Terjira::Client::Project).to receive(:find).with(projects.first.key)

      prompt = TTY::TestPrompt.new
      prompt.input << " "
      prompt.input.rewind
      allow(TTY::Prompt).to receive(:new).and_return(prompt)

      capture(:stdout) {
        described_class.start([:show])
      }
    end
  end
end
