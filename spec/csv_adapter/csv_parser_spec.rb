# frozen_string_literal: true

RSpec.describe(CSVAdapter::CSVParser) do
  describe '#parse!' do
    subject(:parsed_data) do
      described_class.new(filename, validator_proc).parse!
    end

    let(:filename) { 'existing_file.csv' }
    let(:validator_proc) do
      lambda do |row|
        CSVAdapter::Validators::AccountOpeningBalanceValidator.new.call(account_number: row[0], opening_balance: row[1])
      end
    end
    let(:file) do
      CSV.generate do |csv|
        csv << ['1111234522226789', '5000.00']
        csv << %w[1111234522b test]
        csv << []
      end
    end

    before do
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with(filename, 'r', { headers: false, universal_newline: false }).and_return(file)
    end

    it 'returns parsed data details for successful accounts' do
      expect(parsed_data.first.to_h).to eq({ account_number: 1111234522226789, opening_balance: 5000.00 })
    end

    it 'does not return errors for successfully parsed account details' do
      expect(parsed_data.first.errors.to_h).to eq({})
    end

    it 'returns untoched data details for accounts failed validation' do
      expect(parsed_data.last.to_h).to eq({ account_number: '1111234522b', opening_balance: 'test' })
    end

    it 'returns errors for account failed validation' do
      expect(parsed_data.last.errors.to_h).to eq(
        { account_number: ['must be an integer'], opening_balance: ['must be a float'] }
      )
    end

    context 'when file with filename does not exist' do
      it 'raises an error' do
        expect do
          described_class.new('not_found.csv', validator_proc).parse!
        end.to raise_error(CSVAdapter::FileNotFoundError)
      end
    end
  end
end
