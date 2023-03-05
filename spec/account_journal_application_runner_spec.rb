# frozen_string_literal: true

RSpec.describe(AccountJournalApplicationRunner) do
  describe '.run' do
    subject(:run_application) { described_class.run(*params) }

    let(:params) { ['accounts.csv', 'transactions.csv'] }
    let(:account_opening_balances_file) do
      CSV.generate do |csv|
        csv << ['1111234522226789', '5000.00']
        csv << ['1212343433335665', '5000.00']
        csv << %w[1111234522b test]
      end
    end
    let(:transactions_file) do
      CSV.generate do |csv|
        csv << ['1111234522226789', '1212343433335665', '500.00']
        csv << ['1212343433335665', '1212343433335665', '1000.00']
      end
    end

    before do
      # allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with(
        'accounts.csv',
        'r',
        {
          headers: false,
          universal_newline: false
        }
      ).and_return(account_opening_balances_file)
      allow(File).to receive(:open).with(
        'transactions.csv',
        'r',
        { headers: false, universal_newline: false }
      ).and_return(transactions_file)
    end

    it 'displays validation errors' do
      expect do
        run_application
      end.to output(/The following errors detected when parsing input files/).to_stdout
    end

    context 'when CSV Parser raises FileNotFound error' do
      before do
        csv_parser_stub = instance_double(CSVAdapter::CSVParser)
        allow(CSVAdapter::CSVParser).to receive(:new).and_return(csv_parser_stub)
        allow(csv_parser_stub).to receive(:parse!).and_raise(CSVAdapter::FileNotFound.new('oops'))
      end

      it 'logs an input file error' do
        expect do
          run_application
        end.to output("\"ERROR: Unable to parse an input file. oops\"\n").to_stdout
      end
    end
  end
end
