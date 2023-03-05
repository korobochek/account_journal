# frozen_string_literal: true

module Journal
  class UnknownJournalEntryTypeError < StandardError; end

  class JournalEntry
    def initialize(account_number, type, amount)
      @account_number = account_number
      @type = type
      @amount = amount
    end

    attr_reader :account_number, :amount

    def amount_for_balance
      case @type
      when :credit
        @amount
      when :debit
        -@amount
      else
        raise UnknownJournalEntryTypeError, @type
      end
    end
  end
end
