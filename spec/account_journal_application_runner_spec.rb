# frozen_string_literal: true

RSpec.describe(AccountJournalApplicationRunner) do
  describe '.run' do
    subject(:run_application) { described_class.run(*params) }

    let(:params) { ['accounts.csv', 'transactions.csv'] }
    let(:account_opening_balances_file) do
      CSV.generate do |csv|
        csv << ['1111234522226789', '5000.00']
        csv << ['1212343433335665', '3000.00']
        csv << %w[1111234522b test]
      end
    end
    let(:transactions_file) do
      CSV.generate do |csv|
        csv << ['1111234522226789', '1212343433335665', '500.00']
        csv << ['1212343433335665', '1212343433335665', '1000.00']
      end
    end
    let(:valid_and_parsed_account_balances) do
      [
        { account_number: 1111234522226789, opening_balance: 5000.00 },
        { account_number: 1212343433335665, opening_balance: 3000.00 }
      ]
    end
    let(:valid_and_parsed_transactions) do
      [
        { from_account: 1111234522226789, to_account: 1212343433335665, amount: 500.00 }
      ]
    end

    let(:account_journal_service_double) { instance_double(Journal::AccountsJournalService) }

    before do
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

      allow(Journal::AccountsJournalService).to receive(:new).and_return(account_journal_service_double)
      allow(account_journal_service_double).to receive(:start_accounting_period)
      allow(account_journal_service_double).to receive(:process_transactions)
    end

    it 'displays validation errors' do
      expect do
        run_application
      end.to output(/The following errors detected when parsing input files/).to_stdout
    end

    it 'starts accounting period using valid opening balances only' do
      run_application
      expect(account_journal_service_double).to have_received(:start_accounting_period).with(
        valid_and_parsed_account_balances
      )
    end

    it 'starts initiatiated=s processing for successfull transactions only' do
      run_application
      expect(account_journal_service_double).to have_received(:process_transactions).with(
        valid_and_parsed_transactions
      )
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
