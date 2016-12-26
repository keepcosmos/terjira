require 'spec_helper'
require 'terjira/client/field'
require 'terjira/utils/file_cache'

describe Terjira::Client::Field do
  let(:fields) { MockResource.fields }

  before :each do
    allow(described_class).to receive(:all).and_return(fields)
  end

  it 'find by key' do
    field = described_class.find_by_key('issuetype')
    expect(field.key).to eq 'issuetype'
    expect(field.name).to eq 'Issue Type'
  end

  it 'find by name' do
    field = described_class.find_by_name('Story Points')
    expect(field.key).to eq 'customfield_10022'
    expect(field.name).to eq 'Story Points'
  end

  it 'find by named field method' do
    expect(described_class.epic_name).to be_present
    expect(described_class.epic_link).to be_present
    expect(described_class.story_points).to be_present
  end
end
