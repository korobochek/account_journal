# frozen_string_literal: true

require_relative 'csv_adapter/csv_parser'
require_relative 'csv_adapter/validators/account_opening_balance_validator'

module AccountJournalApplication
  def self.run(account_opening_balances_filename, transactions_filename, account_closing_balances_filename = nil)
    validated_opening_balances = parse_opening_balances(account_opening_balances_filename)

    p transactions_filename
    p account_closing_balances_filename
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
end
