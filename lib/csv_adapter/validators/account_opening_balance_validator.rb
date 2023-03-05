# frozen_string_literal: true

require 'dry-validation'

module CSVAdapter
  module Validators
    class AccountOpeningBalanceValidator < Dry::Validation::Contract
      params do
        required(:account_number).filled(:integer)
        required(:opening_balance).filled(:float)
      end

      rule(:account_number) do
        key.failure('must be a 16 digit number') unless value.digits.length == 16
      end

      rule(:opening_balance) do
        key.failure('must be a positive number') if value.negative?
      end
    end
  end
end
