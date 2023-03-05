# frozen_string_literal: true

RSpec.describe(CSVAdapter::Validators::TransactionValidator) do
  describe '#call' do
    subject(:validation_contract_result) do
      described_class.new.call(from_account:, to_account:, amount:)
    end

    let(:from_account)  { '1111234522226789' }
    let(:to_account)    { '1111234522226790' }
    let(:amount)        { '500.00' }

    it 'passes validation' do
      expect(validation_contract_result.success?).to be(true)
    end

    it 'returns parsed transaction details' do
      parsed_transactions = { from_account: 1111234522226789, to_account: 1111234522226790, amount: 500.00 }

      expect(validation_contract_result.to_h).to eq(parsed_transactions)
    end

    context 'when from_account and to_account numbers are not an integer' do
      let(:from_account) { 'acc_number_123' }
      let(:to_account)   { 'acc_number_121' }

      it 'fails validation' do
        expect(validation_contract_result.success?).to be(false)
      end

      it 'returns type validation error for an from_account field' do
        expect(validation_contract_result.errors[:from_account]).to eq(['must be an integer'])
      end

      it 'returns type validation error for an to_account field' do
        expect(validation_contract_result.errors[:to_account]).to eq(['must be an integer'])
      end
    end

    context 'when from_account and to_account numbers are less than 16 digits' do
      let(:from_account) { '1111234522226' }
      let(:to_account)   { '11112345222' }

      it 'returns from_account number length validation error' do
        expect(validation_contract_result.errors[:from_account]).to eq(['must be a 16 digit number'])
      end

      it 'returns to_account number length validation error' do
        expect(validation_contract_result.errors[:to_account]).to eq(['must be a 16 digit number'])
      end
    end

    context 'when from account and to_account numbers are greater than 16 digits' do
      let(:from_account) { '1111234522226789123' }
      let(:to_account)   { '1111234522226789128' }

      it 'returns from_account number length validation error' do
        expect(validation_contract_result.errors[:from_account]).to eq(['must be a 16 digit number'])
      end

      it 'returns to_account number length validation error' do
        expect(validation_contract_result.errors[:to_account]).to eq(['must be a 16 digit number'])
      end
    end

    context 'when from account number is equal to to_account number' do
      let(:from_account) { '1111234522226789' }
      let(:to_account)   { '1111234522226789' }

      it 'returns to_account number suplicate account_number validation error' do
        expect(validation_contract_result.errors[:to_account]).to eq(['must not equal to origin account number'])
      end
    end

    context 'when amount is an integer' do
      let(:amount) { '4' }

      it 'passes validation' do
        expect(validation_contract_result.success?).to be(true)
      end

      it 'returns amount as a float' do
        expect(validation_contract_result.to_h[:amount]).to eq(4.0)
      end
    end

    context 'when amount is a string' do
      let(:amount) { 'test.0' }

      it 'returns type validation error for an amount field' do
        expect(validation_contract_result.errors[:amount]).to eq(['must be a float'])
      end
    end

    context 'when amount is negative' do
      let(:amount) { '-4.0' }

      it 'returns validation error' do
        expect(validation_contract_result.errors[:amount]).to eq(['must be a positive number'])
      end
    end

    context 'when amount and account numbers are nil' do
      let(:from_account) { nil }
      let(:to_account)   { nil }
      let(:amount)       { nil }

      let(:expected_errors) do
        {
          from_account: ['must be filled'],
          to_account: ['must be filled'],
          amount: ['must be filled']
        }
      end

      it 'returns required validation errors' do
        expect(validation_contract_result.errors.to_h).to eq(expected_errors)
      end
    end
  end
end
