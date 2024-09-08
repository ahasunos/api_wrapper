# frozen_string_literal: true

RSpec.describe ApiWrapper do
  it 'has a version number' do
    expect(ApiWrapper::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(true).to eq(true)
  end
end
