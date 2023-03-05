# frozen_string_literal: true

RSpec.describe(CSVInputAdapter::CSVParser) do
  describe '#parse!' do
    subject(:parsed_data) do
      described_class.new(filename, validator).parse!
    end

    let(:filename) { 'existing_file.csv' }
    let(:validator) do
      instance_double(CSVInputAdapter::Validators::AccountOpeningBalanceValidator)
    end
    let(:file) do
      CSV.generate do |csv|
        csv << ['1111234522226789', '5000.00']
        csv << ['1111234522226788', '50.00']
      end
    end

    before do
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with(filename, 'r', { headers: false, universal_newline: false }).and_return(file)
    end

    # it 'returns parsed data details' do
    #   expected_records = {}

    #   expect(parsed_data.parsed_records).to eq(expected_records)
    # end

    # it 'returns no errors' do
    #   expect(parsed_data.errored_records).to eq([])
    # end

    # context 'when some of the file contents are invalid' do
    #   it 'returns parsed data details for valid items' do

    #   end

    #   it 'returns error for errored items' do
    #   end
    # end

    context 'when file with filename does not exist' do
      it 'raises an error' do
        expect do
          described_class.new('not_found.csv', validator).parse!
        end.to raise_error(CSVInputAdapter::FileNotFound)
      end
    end
  end
end
