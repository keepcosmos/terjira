require 'spec_helper'
require 'terjira/version'

describe Terjira::VersionChecker do
  subject { Terjira::VersionChecker }

  it 'must check major version is outdated' do
    stub_const('Terjira::VERSION', '0.10.0')
    allow(Terjira::VersionChecker).to receive(:search_remote_version).and_return("terjira (1.0.0)")

    expect(subject).to be_new_version_exists
  end

  it 'must check minor version is outdated' do
    stub_const('Terjira::VERSION', '0.10.9')
    allow(Terjira::VersionChecker).to receive(:search_remote_version).and_return("terjira (0.11.0)")

    expect(subject).to be_new_version_exists
  end

  it 'must check patch version is outdated' do
    stub_const('Terjira::VERSION', '0.10.9')
    allow(Terjira::VersionChecker).to receive(:search_remote_version).and_return("terjira (0.10.11)")

    expect(subject).to be_new_version_exists
  end

  it 'does not check version is not outdated' do
    stub_const('Terjira::VERSION', '0.10.9')
    allow(Terjira::VersionChecker).to receive(:search_remote_version).and_return("terjira (0.10.9)")

    expect(subject).not_to be_new_version_exists

    stub_const('Terjira::VERSION', '1.0.0')
    allow(Terjira::VersionChecker).to receive(:search_remote_version).and_return("terjira (0.99.9)")

    expect(subject).not_to be_new_version_exists
  end
end
