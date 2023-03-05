# frozen_string_literal: true

module Journal
  class Account
    def initialize(account_number)
      @account_number = account_number
    end

    attr_reader :account_number

    def ==(other)
      other.is_a?(Account) && @account_number == other.account_number
    end
  end
end
