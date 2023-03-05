# frozen_string_literal: true

RSpec.describe(CSVAdapter::Validators::AccountOpeningBalanceValidator) do
  describe '#call' do
    subject(:validation_contract_result) do
      described_class.new.call(account_number:, opening_balance:)
    end

    let(:account_number)  { '1111234522226789' }
    let(:opening_balance) { '500.00' }

    it 'passes validation' do
      expect(validation_contract_result.success?).to eq(true)
    end

    it 'returns parsed data types for an account opening balance' do
      parsed_balance = { account_number: 1111234522226789, opening_balance: 500.00 }

      expect(validation_contract_result.to_h).to eq(parsed_balance)
    end

    context 'when account number is not an integer' do
      let(:account_number)  { 'acc_number_123' }

      it 'fails validation' do
        expect(validation_contract_result.success?).to eq(false)
      end

      it 'returns type validation error for an account_number field' do
        expect(validation_contract_result.errors[:account_number]).to eq(['must be an integer'])
      end
    end

    context 'when account number is less than 16 digits' do
      let(:account_number) { '1111234522226' }

      it 'returns account number length validation error' do
        expect(validation_contract_result.errors[:account_number]).to eq(['must be a 16 digit number'])
      end
    end

    context 'when account number is greater than 16 digits' do
      let(:account_number) { '1111234522226789123' }

      it 'returns account number length validation error' do
        expect(validation_contract_result.errors[:account_number]).to eq(['must be a 16 digit number'])
      end
    end

    context 'when opening balance is an integer' do
      let(:opening_balance) { '4' }

      it 'passes validation' do
        expect(validation_contract_result.success?).to eq(true)
      end

      it 'returns opening balance as a float' do
        expect(validation_contract_result.to_h[:opening_balance]).to eq(4.0)
      end
    end

    context 'when opening balance is a string' do
      let(:opening_balance) { 'test.0' }

      it 'returns type validation error for an opening_balance field' do
        expect(validation_contract_result.errors[:opening_balance]).to eq(['must be a float'])
      end
    end

    context 'when opening balance is negative' do
      let(:opening_balance) { '-4.0' }

      it 'returns validation error' do
        expect(validation_contract_result.errors[:opening_balance]).to eq(['must be a positive number'])
      end
    end

    context 'when opening balance and account number are nil' do
      let(:account_number) { nil }
      let(:opening_balance) { nil }

      it 'returns required validation errors' do
        expected_errors = { account_number: ['must be filled'], opening_balance: ['must be filled'] }

        expect(validation_contract_result.errors.to_h).to eq(expected_errors)
      end
    end
  end
end
