# frozen_string_literal: true

RSpec.describe(Journal::AccountsJournalService) do
  subject(:account_journal_service) { described_class.new }

  let(:opening_balances) do
    [
      { account_number: 1111234522226789, opening_balance: 5000.00 },
      { account_number: 1111234522221234, opening_balance: 10000.00 },
      { account_number: 2222123433331212, opening_balance: 550.00 },
      { account_number: 1212343433335665, opening_balance: 1200.00 },
      { account_number: 3212343433335755, opening_balance: 50000.00 }
    ]
  end

  let(:transactions) do
    [
      { from_account: 1111234522226789, to_account: 1212343433335665, amount: 500.00 },
      { from_account: 3212343433335755, to_account: 2222123433331212, amount: 1000.00 },
      { from_account: 1111234522221234, to_account: 1212343433335665, amount: 12000.00 },
      { from_account: 3212343433335755, to_account: 1111234522226789, amount: 320.50 },
      { from_account: 1111234522221333, to_account: 1212343433335665, amount: 25.60 },
      { from_account: 1111234522226789, to_account: 1212343433335665, amount: 5000.00 },
      { from_account: 1111234522226789, to_account: 1212343433311111, amount: 5000.00 },
    ]
  end

  describe '#start_accounting_period' do
    before do
      account_journal_service.start_accounting_period(opening_balances)
    end

    it 'creates a journal withing a general ledger-like journal representation for foeach account' do
      expect(account_journal_service.accounts_journal.count).to eq(5)
    end

    it 'creates 5 journal entries' do
      expect(account_journal_service.accounts_journal.values.flatten.count).to eq(5)
    end

    it 'loads and calculates account balances correctly' do
      result = opening_balances.map do |balance| 
        balance[:balance] = balance.delete(:opening_balance)
        balance
      end
      expect(account_journal_service.account_balances).to eq(result)
    end

    # TODO: USE CASE: when multiple initial account balances for the same account
  end

  describe '#process_transactions' do
    before do
      account_journal_service.start_accounting_period(opening_balances)
      account_journal_service.process_transactions(transactions)
    end

    let(:expected_balances) do
      [
        { account_number: 1111234522226789, balance: 4820.50 },
        { account_number: 1111234522221234, balance: 10000.00 },
        { account_number: 2222123433331212, balance: 1550.00 },
        { account_number: 1212343433335665, balance: 1700.00 },
        { account_number: 3212343433335755, balance: 48679.50 }
      ]
    end

    it 'processes valid transactions as appropriate debits and credit that are reflected in account balances' do
      expect(account_journal_service.account_balances).to eq(expected_balances)
    end

    it 'logs all provided transactions in the transactions log' do
      expect(account_journal_service.transaction_log.count).to eq(7)
    end

    it 'allows for failed transaction retrieval with failure reasons' do
      expect(account_journal_service.list_failed_transactions).to eq(
        [
          { from_account: 1111234522221234, to_account: 1212343433335665, amount: 12000.00, status: :failed,  failure_reason: 'insufficent funds' },
          { from_account: 1111234522221333, to_account: 1212343433335665, amount: 25.60, status: :failed,  failure_reason: 'unknown source and/or destination accounts' },
          { from_account: 1111234522226789, to_account: 1212343433335665, amount: 5000.00 , status: :failed,  failure_reason: 'insufficent funds' },
          { from_account: 1111234522226789, to_account: 1212343433311111, amount: 5000.00, status: :failed,  failure_reason: 'unknown source and/or destination accounts' }
        ]
      )
    end
  end
end
