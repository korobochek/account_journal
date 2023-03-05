# frozen_string_literal: true

require_relative 'csv_adapter/csv_parser'
require_relative 'csv_adapter/validators/account_opening_balance_validator'

module AccountJournalApplication
  def self.run(account_opening_balances_filename, transactions_filename, account_closing_balances_filename = nil)
    validated_opening_balances = CSVAdapter::CSVParser.new(
      account_opening_balances_filename,
      CSVAdapter::Validators::AccountOpeningBalanceValidator.new
    ).parse!

    p transactions_filename
    p account_closing_balances_filename
  rescue CSVAdapter::FileNotFound => e
    p "ERROR: Unable to parse an input file. #{e.message}"
  end
end
