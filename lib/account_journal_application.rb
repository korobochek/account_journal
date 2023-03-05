# frozen_string_literal: true

require_relative 'csv_adapter/csv_parser'
require_relative 'csv_adapter/validators/account_opening_balance_validator'
require_relative 'csv_adapter/validators/transaction_validator'

module AccountJournalApplication
  def self.run(account_opening_balances_filename, transactions_filename, account_closing_balances_filename = nil)
    validated_opening_balances = parse_opening_balances(account_opening_balances_filename)
    validated_transactions = parse_transactions(transactions_filename)
    
  rescue CSVAdapter::FileNotFound => e
    p "ERROR: Unable to parse an input file. #{e.message}"
  end

  def self.parse_opening_balances(account_opening_balances_filename)
    CSVAdapter::CSVParser.new(
      account_opening_balances_filename,
      lambda do |row|
        CSVAdapter::Validators::AccountOpeningBalanceValidator.new.call(account_number: row[0], opening_balance: row[1])
      end
    ).parse!
  end

  def self.parse_transactions(transactions_filename)
    CSVAdapter::CSVParser.new(
      transactions_filename,
      lambda do |row|
        CSVAdapter::Validators::TransactionValidator.new.call(from_account: row[0], to_account: row[1], amount: row[3])
      end
    ).parse!
  end
end
