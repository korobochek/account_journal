# frozen_string_literal: true

require_relative 'models/account'
require_relative 'models/journal_entry'

module Journal
  class AccountsJournalService
    def initialize
      # NOTE: I am actively avoding using 'ledger' as a terminology here
      # since 'ledger' comes with a large acconting conotations and business logic like balancing sheets and others
      @accounts_journal = {}
    end

    attr_reader :accounts_journal

    def start_accounting_period(accounts_opening_balances)
      accounts_opening_balances.each do |opening_balance_record|
        account = Journal::Account.new(opening_balance_record[:account_number])
        journal_entry = Journal::JournalEntry.new(account, :credit, opening_balance_record[:opening_balance])

        accounts_journal[account] ||= []
        accounts_journal[account] << journal_entry
      end
    end

    def account_balances
      accounts_journal.map do |account, journal_entries|
        # TODO: change to be 'balance' everywhere - makes thinks easier
        { account_number: account.account_number, opening_balance: journal_entries.sum(&:amount_for_balance) }
      end
    end
  end
end
