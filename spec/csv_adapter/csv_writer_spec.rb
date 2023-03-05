# frozen_string_literal: true

RSpec.describe(CSVAdapter::CSVWriter) do
  describe '#write!' do
    context 'when file provided has a non-existent directory path' do
      it 'raises an error' do
        expect do
          described_class.new('rubbish/not_found.csv', []).write!
        end.to raise_error(CSVAdapter::FileNotFoundError)
      end
    end
  end
end
