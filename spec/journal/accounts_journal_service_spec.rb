# frozen_string_literal: true

RSpec.describe(Journal::AccountsJournalService) do
  let(:accounting_service) { described_class.new }
  let(:opening_balances) do
    [
      { account_number: 1111234522226789, opening_balance: 5000.00 },
      { account_number: 1111234522221234, opening_balance: 10000.00 },
      { account_number: 2222123433331212, opening_balance: 550.00 },
      { account_number: 1212343433335665, opening_balance: 1200.00 },
      { account_number: 3212343433335755, opening_balance: 50000.00 }
    ]
  end

  describe '#start_accounting_period' do
    subject(:start_accounting_period) { accounting_service.start_accounting_period(opening_balances) }

    before do
      start_accounting_period
    end

    it 'creates a journal withing a general ledger-like journal representation for foeach account' do
      expect(accounting_service.accounts_journal.count).to eq(5)
    end

    it 'creates 5 journal entries' do
      expect(accounting_service.accounts_journal.values.flatten.count).to eq(5)
    end

    it 'loads and calculates account balances correctly' do
      expect(accounting_service.account_balances).to eq(opening_balances)
    end

    # TODO: USE CASE: when multiple initial account balances for the same account
  end
end
