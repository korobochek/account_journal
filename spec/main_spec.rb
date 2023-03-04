# frozen_string_literal: true

require 'main'

RSpec.describe('main') do
  it 'returns "hello"' do
    expect(hello).to(eq('hello'))
  end
end
