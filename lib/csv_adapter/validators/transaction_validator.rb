# frozen_string_literal: true

require 'dry-validation'

module CSVAdapter
  module Validators
    class TransactionValidator < Dry::Validation::Contract
      params do
        required(:from_account).filled(:integer)
        required(:to_account).filled(:integer)
        required(:amount).filled(:float)
      end

      rule(:from_account) do
        key.failure('must be a 16 digit number') unless value.digits.length == 16
      end

      rule(:to_account) do
        key.failure('must be a 16 digit number') unless value.digits.length == 16
        key.failure('must not equal to origin account number') if values[:from_account] == values[:to_account]
      end

      rule(:amount) do
        key.failure('must be a positive number') if value.negative?
      end
    end
  end
end
