# frozen_string_literal: true

module Journal
  class Transaction
    def initialize(debit_journal_entry, credit_journal_entry)
      @debit_journal_entry = debit_journal_entry
      @credit_journal_entry = credit_journal_entry
      @status = :processing
      @failure_reason = ''
    end

    attr_reader :status

    def process
      @status = :processed
    end

    def fail(reason)
      @status = :failed
      @failure_reason = reason
    end

    def to_h
      {
        from_account: @debit_journal_entry.account.account_number,
        to_account: @credit_journal_entry.account.account_number,
        amount: @credit_journal_entry.amount,
        status:,
        failure_reason: @failure_reason
      }
    end
  end
end
