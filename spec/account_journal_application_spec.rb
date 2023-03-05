# frozen_string_literal: true

RSpec.describe(AccountJournalApplication) do
  describe '.run' do
    subject(:run_application) { described_class.run(*params) }

    let(:params) { ['input_file', 'output_file'] }

    before do
      csv_parser_stub = instance_double(CSVInputAdapter::CSVParser)
      allow(CSVInputAdapter::CSVParser).to receive(:new).and_return(csv_parser_stub)
      allow(csv_parser_stub).to receive(:parse!).and_return([])
    end

    context 'when CSV Parser raises FileNotFound error' do
      before do
        csv_parser_stub = instance_double(CSVInputAdapter::CSVParser)
        allow(CSVInputAdapter::CSVParser).to receive(:new).and_return(csv_parser_stub)
        allow(csv_parser_stub).to receive(:parse!).and_raise(CSVInputAdapter::FileNotFound.new('oops'))
      end

      it 'logs an input file error' do
        expect do
          run_application
        end.to output( "\"ERROR: Unable to parse an input file. oops\"\n").to_stdout
      end
    end
  end
end
