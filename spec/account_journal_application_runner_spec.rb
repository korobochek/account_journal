# frozen_string_literal: true

RSpec.describe(AccountJournalApplicationRunner) do
  describe '.run' do
    subject(:run_application) { described_class.run(*params) }

    let(:params) { ['accounts.csv', 'transactions.csv', 'output.csv'] }
    let(:expected_closing_balances) do
      [
        [1111234522226789, 4500.00],
        [1212343433335665, 3500.00]
      ]
    end
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

    let(:account_journal_service_double) { instance_double(Journal::AccountsJournal) }

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
      allow(File).to receive(:open).with(
        'output.csv',
        'w',
        { universal_newline: false }
      ).and_return(instance_double(File, close: nil, '<<' => nil))
    end

    it 'starts accounting period using valid opening balances only' do
      expect_any_instance_of(Journal::AccountsJournal).to receive(:start_accounting_period).with(
        valid_and_parsed_account_balances
      )
      run_application
    end

    it 'starts processing successfull transactions only' do
      expect_any_instance_of(Journal::AccountsJournal).to receive(:process_transactions).with(
        valid_and_parsed_transactions
      )
      run_application
    end

    it 'displays validation errors' do
      expect do
        run_application
      end.to output(/The following errors detected when parsing input files/).to_stdout
    end

    it 'writes closing balances file' do
      writer = instance_double(CSVAdapter::CSVWriter, write!: nil)
      allow(CSVAdapter::CSVWriter).to receive(:new).with('output.csv', expected_closing_balances).and_return(writer)

      run_application
      expect(writer).to have_received(:write!)
    end

    context 'when CSV Parser raises FileNotFounError error' do
      before do
        csv_parser_stub = instance_double(CSVAdapter::CSVParser)
        allow(CSVAdapter::CSVParser).to receive(:new).and_return(csv_parser_stub)
        allow(csv_parser_stub).to receive(:parse!).and_raise(CSVAdapter::FileNotFoundError.new('oops'))
      end

      it 'logs an input file error' do
        expect do
          run_application
        end.to output("\"ERROR: File does not exist. oops\"\n").to_stdout
      end
    end
  end
end
