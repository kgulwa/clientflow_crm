# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Note, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:client) }
  end

  describe 'validations' do
    subject(:note) { build(:note) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:content) }
  end
end