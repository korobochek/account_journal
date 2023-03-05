# frozen_string_literal: true

module Journal
  class Transaction
    def initialize(debit, credit)
      @debit = debit
      @credit = credit
      @status = :processing
      @failure_reason = ''
    end

    attr_reader :status, :debit, :credit

    def process
      @status = :processed
    end

    def fail(reason)
      @status = :failed
      @failure_reason = reason
    end

    def to_h
      {
        from_account: @debit.account_number,
        to_account: @credit.account_number,
        amount: @credit.amount,
        status:,
        failure_reason: @failure_reason
      }
    end
  end
end
