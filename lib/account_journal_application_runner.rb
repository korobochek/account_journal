# frozen_string_literal: true

require_relative 'csv_adapter/csv_parser'
require_relative 'csv_adapter/validators/account_opening_balance_validator'
require_relative 'csv_adapter/validators/transaction_validator'

require_relative 'journal/accounts_journal_service'

module AccountJournalApplicationRunner
  def self.run(account_opening_balances_filename, transactions_filename, _account_closing_balances_filename = nil)
    validated_opening_balances = parse_opening_balances(account_opening_balances_filename)
    validated_transactions = parse_transactions(transactions_filename)
    print_validation_errors(validated_opening_balances.select(&:failure?), validated_transactions.select(&:failure?))

    accounts_journal_service = Journal::AccountsJournalService.new
    accounts_journal_service.start_accounting_period(validated_opening_balances.select(&:success?).map(&:to_h))
    accounts_journal_service.process_transactions(validated_transactions.select(&:success?).map(&:to_h))
  rescue CSVAdapter::FileNotFound => e
    p "ERROR: Unable to parse an input file. #{e.message}"
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

  private_class_method def self.print_validation_errors(balance_errors, transaction_errors)
    return if balance_errors.none? && transaction_errors.none?

    p 'The following errors detected when parsing input files:'
    print_errors('Failed to load balance', balance_errors)
    print_errors('Failed to load transaction', transaction_errors)
  end

  private_class_method def self.print_errors(prefix, results)
    results.each do |result|
      p "#{prefix} for: #{result.to_h.values.join(',')}. Errors detected: #{result.errors.to_h}"
    end
  end
end
