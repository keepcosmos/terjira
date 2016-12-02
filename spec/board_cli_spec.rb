require 'spec_helper'

describe Terjira::BoardCLI do

  context "#list" do
    it 'must show boads' do
      boards = MockResource.boards
      allow(Terjira::Client::Board).to receive(:all).and_return(boards)

      result = capture(:stdout) { described_class.start([:list]) }

      boards.each do |board|
        expect(result).to be_include board.id.to_s
        expect(result).to be_include board.name
        expect(result).to be_include board.type
      end
    end
  end
end
