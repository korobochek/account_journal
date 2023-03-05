# frozen_string_literal: true

require_relative 'csv_input_adapter/csv_parser'
require_relative 'csv_input_adapter/validators/account_opening_balance_validator'

module AccountJournalApplication
  def self.run(account_opening_balances_filename, transactions_filename, account_closing_balances_filename = nil)
    validated_opening_balances = CSVInputAdapter::CSVParser.new(
      account_opening_balances_filename,
      CSVInputAdapter::Validators::AccountOpeningBalanceValidator.new
    ).parse!

    p transactions_filename
    p account_closing_balances_filename
  rescue CSVInputAdapter::FileNotFound => e
    p "ERROR: Unable to parse an input file. #{e.message}"
  end
end
