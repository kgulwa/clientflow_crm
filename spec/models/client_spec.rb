# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Client, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }

    it do
      expect(described_class.reflect_on_association(:client_notes))
        .to have_attributes(
          class_name: 'Note',
          macro: :has_many
        )
    end

    it { is_expected.to have_many(:tasks).dependent(:destroy) }
    it { is_expected.to have_many(:contacts).dependent(:destroy) }

    it 'destroys associated client notes' do
      client = create(:client)
      note = create(:note, client: client)

      client.destroy

      expect(Note.exists?(note.id)).to be(false)
    end

    it 'destroys associated tasks' do
      client = create(:client)
      task = create(:task, client: client)

      client.destroy

      expect(Task.exists?(task.id)).to be(false)
    end

    it 'destroys associated contacts' do
      client = create(:client)
      contact = create(:contact, client: client)

      client.destroy

      expect(Contact.exists?(contact.id)).to be(false)
    end
  end

  describe 'validations' do
    subject(:client) { build(:client) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe 'statuses' do
    it 'defines lead, active, and inactive statuses' do
      expect(described_class.statuses).to eq(
        'lead' => 0,
        'active' => 1,
        'inactive' => 2
      )
    end

    it 'defaults new clients to lead status' do
      client = described_class.new

      expect(client).to be_lead
    end
  end

  describe '#full_name' do
    it "returns the client's first and last name" do
      client = build(
        :client,
        first_name: 'Sarah',
        last_name: 'Johnson'
      )

      expect(client.full_name).to eq('Sarah Johnson')
    end
  end
end