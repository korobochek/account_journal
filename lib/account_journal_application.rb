# frozen_string_literal: true

class AccountJournalApplication
  def self.run(account_opening_balances_filename, transactions_filename, account_closing_balances_filename = nil)
    p account_opening_balances_filename
    p transactions_filename
    p account_closing_balances_filename
  end
end
