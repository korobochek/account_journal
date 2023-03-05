# frozen_string_literal: true

require_relative 'models/journal_entry'

module Journal
  class InsufficentFundsError < StandardError; end
  class UnknownAccountError < StandardError; end

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
        account_number = opening_balance_record[:account_number]
        journal_entry = Journal::JournalEntry.new(account_number, :credit, opening_balance_record[:opening_balance])

        accounts_journal[account_number] ||= []
        accounts_journal[account_number] << journal_entry
      end
    end

    def process_transactions(transactions)
      transactions.each do |txn|
        process_transaction(txn)
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

    def process_transaction(txn)
      logged_transaction = build_transaction_to_log(txn[:from_account], txn[:to_account], txn[:amount])
      process_debit(logged_transaction.debit)
      process_credit(logged_transaction.credit)
      logged_transaction.process
    rescue UnknownAccountError, InsufficentFundsError => e
      logged_transaction.fail(e.message)
    ensure
      @transaction_log << logged_transaction
    end

    def build_transaction_to_log(from_account, to_account, amount)
      debit = Journal::JournalEntry.new(from_account, :debit, amount)
      credit = Journal::JournalEntry.new(to_account, :credit, amount)
      Journal::Transaction.new(debit, credit)
    end

    def process_debit(debit)
      from_account_journal_entries = accounts_journal[debit.account_number]
      raise UnknownAccountError, 'unknown source and/or destination accounts' unless from_account_journal_entries

      from_account_balance = calculate_balance_from_journal_entries(from_account_journal_entries)
      raise InsufficentFundsError, 'insufficent funds' if debit.amount > from_account_balance

      accounts_journal[debit.account_number] << debit
    end

    def process_credit(credit)
      to_account_journal_entries = accounts_journal[credit.account_number]
      raise UnknownAccountError, 'unknown source and/or destination accounts' unless to_account_journal_entries

      accounts_journal[credit.account_number] << credit
    end

    def calculate_balance_from_journal_entries(journal_entries)
      journal_entries.sum(&:amount_for_balance)
    end
  end
end
