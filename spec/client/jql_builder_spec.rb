require 'spec_helper'
require 'terjira/client/jql_builder'

class TestJQLBuilder
  extend Terjira::Client::JQLBuilder
end

describe Terjira::Client::JQLBuilder do
  subject { TestJQLBuilder }

  describe 'strict_matching' do
    it 'builds string value jql' do
      result = subject.send(:strict_matching, {sprint: 1})
      expect(result).to be == 'sprint=1'

      result = subject.send(:strict_matching, {issuetype: 'Task'})
      expect(result).to be == 'issuetype="Task"'
    end

    it 'builds array value jql' do
      result = subject.send(:strict_matching, {sprint: [1, 2, 3]})
      expect(result).to be == 'sprint IN ("1","2","3")'

      result = subject.send(:strict_matching,  {priority: %w(high low)})
      expect(result).to be == 'priority IN ("high","low")'
    end

    it 'builds multiple key values jql' do
      result = subject.send(:strict_matching, {sprint: 1, issuetype: %w(Task Done)})

      expect(result).to be == 'sprint=1 AND issuetype IN ("Task","Done")'
    end
  end

  describe 'search_matching' do
    it 'builds string value jql' do
      result = subject.send(:search_matching, {summary: 'very important issue'})
      expect(result).to be == 'summary~"very important issue"'
    end

    it 'filter usupported JQL key' do
      result = subject.send(:search_matching, {foo: 'bar'})
      expect(result).to be == ''
    end
  end

  describe 'build_jql' do
    it 'merges queries properly' do
      result = subject.build_jql(sprint: [1, 2], summary: 'foo')
      expect(result).to be == 'sprint IN ("1","2") AND summary~"foo"'
    end

    it 'handles empty results' do
      result = subject.build_jql(sprint: [1, 2])
      expect(result).to be == 'sprint IN ("1","2")'
    end
  end
end
