# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notification, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:actor).class_name("User") }
    it { is_expected.to belong_to(:task) }
  end

  describe "validations" do
    subject(:notification) { build(:notification) }

    it { is_expected.to validate_presence_of(:message) }
  end

  describe "scopes" do
    it "returns unread notifications" do
      unread_notification = create(:notification, read_at: nil)
      create(:notification, read_at: Time.current)

      expect(described_class.unread).to contain_exactly(unread_notification)
    end

    it "returns read notifications" do
      create(:notification, read_at: nil)
      read_notification = create(:notification, read_at: Time.current)

      expect(described_class.read).to contain_exactly(read_notification)
    end
  end

  describe "#read?" do
    it "returns false when read_at is blank" do
      notification = build(:notification, read_at: nil)

      expect(notification).not_to be_read
    end

    it "returns true when read_at is present" do
      notification = build(:notification, read_at: Time.current)

      expect(notification).to be_read
    end
  end

  describe "#mark_as_read!" do
    it "sets read_at" do
      notification = create(:notification, read_at: nil)

      expect do
        notification.mark_as_read!
      end.to change(notification, :read_at).from(nil)
    end
  end
end