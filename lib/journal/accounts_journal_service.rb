# frozen_string_literal: true

require_relative 'models/account'
require_relative 'models/journal_entry'

module Journal
  class AccountsJournalService
    def initialize
      # NOTE: I am actively avoding using 'ledger' as a terminology here
      # since 'ledger' comes with a large acconting conotations and business logic like balancing sheets and others
      @accounts_journal = {}
      @transaction_log = []
    end

    attr_reader :accounts_journal, :transaction_log

    def start_accounting_period(accounts_opening_balances)
      accounts_opening_balances.each do |opening_balance_record|
        # the only reason it exists here is to suppor extension across multiple companies
        account = Journal::Account.new(opening_balance_record[:account_number])
        journal_entry = Journal::JournalEntry.new(account, :credit, opening_balance_record[:opening_balance])

        # this is looking a bit unnecessary unless you consider account containing the owner entity details
        accounts_journal[account.account_number] ||= []
        accounts_journal[account.account_number] << journal_entry
      end
    end

    def process_transactions(transactions)
      transactions.each do |txn|
        from_account = Journal::Account.new(txn[:from_account])
        debit_journal_entry = Journal::JournalEntry.new(from_account, :debit, txn[:amount])

        to_account = Journal::Account.new(txn[:to_account])
        credit_journal_entry = Journal::JournalEntry.new(to_account, :credit, txn[:amount])
        
        transaction_instance = Journal::Transaction.new(debit_journal_entry, credit_journal_entry)
        
        from_account_journal_entries = accounts_journal[txn[:from_account]]
        to_account_journal_entries = accounts_journal[txn[:to_account]]

        if from_account_journal_entries && to_account_journal_entries
          current_balance = calculate_balance_from_journal_entries(from_account_journal_entries)

          if txn[:amount] <= current_balance
            accounts_journal[from_account.account_number] << debit_journal_entry
            accounts_journal[to_account.account_number] << credit_journal_entry
            transaction_instance.process
          else
            transaction_instance.fail('insufficent funds')
          end
        else
          transaction_instance.fail('unknown source and/or destination accounts')
        end

        @transaction_log << transaction_instance
      end
    end

    def list_failed_transactions
      failed_txns = @transaction_log.select { |txn| txn.status == :failed }
      failed_txns.map(&:to_h)
    end

    def account_balances
      accounts_journal.map do |account, journal_entries|
        { account_number: account, balance: calculate_balance_from_journal_entries(journal_entries) }
      end
    end

    private

    def calculate_balance_from_journal_entries(journal_entries)
      journal_entries.sum(&:amount_for_balance)
    end
  end
end
