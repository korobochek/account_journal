# frozen_string_literal: true

module Journal
  class UnknownJournalEntryTypeError < StandardError; end

  class JournalEntry
    def initialize(account, type, amount)
      @account = account
      @type = type
      @amount = amount
    end

    attr_reader :account, :amount

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
