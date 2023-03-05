# frozen_string_literal: true

require 'time'

require_relative 'csv_adapter/csv_parser'
require_relative 'csv_adapter/csv_writer'
require_relative 'csv_adapter/validators/account_opening_balance_validator'
require_relative 'csv_adapter/validators/transaction_validator'

require_relative 'journal/accounts_journal_service'

module AccountJournalApplicationRunner
  def self.run(account_opening_balances_filename, transactions_filename, account_closing_balances_filename = nil)
    validated_opening_balances = parse_opening_balances(account_opening_balances_filename)
    validated_transactions = parse_transactions(transactions_filename)
    print_validation_errors(validated_opening_balances.select(&:failure?), validated_transactions.select(&:failure?))

    run_account_journal_service(validated_opening_balances, validated_transactions, account_closing_balances_filename)
  rescue CSVAdapter::FileNotFound => e
    p "ERROR: File does not exist. #{e.message}"
  end

  private_class_method def self.parse_opening_balances(account_opening_balances_filename)
    CSVAdapter::CSVParser.new(
      account_opening_balances_filename,
      lambda do |row|
        CSVAdapter::Validators::AccountOpeningBalanceValidator.new.call(account_number: row[0], opening_balance: row[1])
      end
    ).parse!
  end

  private_class_method def self.parse_transactions(transactions_filename)
    CSVAdapter::CSVParser.new(
      transactions_filename,
      lambda do |row|
        CSVAdapter::Validators::TransactionValidator.new.call(from_account: row[0], to_account: row[1], amount: row[2])
      end
    ).parse!
  end

  private_class_method def self.run_account_journal_service(opening_balances, transactions, closing_balances_filename)
    accounts_journal_service = Journal::AccountsJournalService.new
    accounts_journal_service.start_accounting_period(opening_balances.select(&:success?).map(&:to_h))
    accounts_journal_service.process_transactions(transactions.select(&:success?).map(&:to_h))
    save_closing_balances(closing_balances_filename, accounts_journal_service.account_balances)
    print_transaction_processing_failures(accounts_journal_service.list_failed_transactions)
  end

  private_class_method def self.print_validation_errors(balance_errors, transaction_errors)
    return if balance_errors.none? && transaction_errors.none?

    p 'The following errors detected when parsing input files:'
    print_validation_results('Failed to load balance', balance_errors)
    print_validation_results('Failed to load transaction', transaction_errors)
  end

  private_class_method def self.print_validation_results(prefix, results)
    results.each do |result|
      p "#{prefix} for: #{result.to_h.values.join(',')}. Errors detected: #{result.errors.to_h}"
    end
  end

  private_class_method def self.print_transaction_processing_failures(failed_txns)
    return if failed_txns.none?

    p 'The following transactions failed to be processed:'
    failed_txns.each do |txn|
      p txn
    end
  end

  private_class_method def self.save_closing_balances(account_closing_balances_filename, closing_balances)
    account_closing_balances_filename ||= "#{Time.now.strftime('%m_%d_%Y')}_closing_balances.csv"
    CSVAdapter::CSVWriter.new(account_closing_balances_filename, closing_balances.map(&:values)).write!
  end
end
