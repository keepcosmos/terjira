require 'spec_helper'
require 'terjira/client/jql_builder'

class TestJQLBuilder
  extend Terjira::Client::JQLBuilder
end

describe Terjira::Client::JQLBuilder do
  subject { TestJQLBuilder }

  it 'builds string value jql' do
    result = subject.build_jql(board: 1)
    expect(result).to be == 'board=1'

    result = subject.build_jql(issuetype: 'Task')
    expect(result).to be == 'issuetype=Task'
  end

  it 'builds array value jql' do
    result = subject.build_jql(sprint: [1, 2, 3])
    expect(result).to be == 'sprint IN ("1","2","3")'

    result = subject.build_jql(priority: %w(high low))
    expect(result).to be == 'priority IN ("high","low")'
  end

  it 'builds multiple key values jql' do
    result = subject.build_jql(sprint: 1, issuetype: %w(Task Done))

    expect(result).to be == 'sprint=1 AND issuetype IN ("Task","Done")'
  end

  it 'filters unkown jql key' do
    result = subject.build_jql(unkown: 1)
    expect(result).to be == ''
  end
end
