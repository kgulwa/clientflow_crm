# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    subject(:user) { build(:user) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:role) }
  end

  describe "roles" do
    it "defines member and admin roles" do
      expect(described_class.roles).to eq(
        "member" => 0,
        "admin" => 1
      )
    end

    it "defaults new users to the member role" do
      user = described_class.new

      expect(user).to be_member
    end
  end

  describe "active state" do
    it "defaults new users to active" do
      user = described_class.new

      expect(user).to be_active
    end

    it "returns only active users from the active scope" do
      active_user = create(:user)
      inactive_user = create(
        :user,
        active: false,
        deactivated_at: Time.current
      )

      expect(described_class.active).to include(active_user)
      expect(described_class.active).not_to include(inactive_user)
    end
  end

  describe "#full_name" do
    it "returns the user's first and last name" do
      user = build(
        :user,
        first_name: "Konke",
        last_name: "Gulwa"
      )

      expect(user.full_name).to eq("Konke Gulwa")
    end
  end

  describe "#deactivate!" do
    it "marks the user as inactive" do
      user = create(:user)

      user.deactivate!

      expect(user.reload).not_to be_active
    end

    it "records when the user was deactivated" do
      user = create(:user)

      user.deactivate!

      expect(user.reload.deactivated_at).to be_present
    end
  end

  describe "#activate!" do
    it "marks the user as active" do
      user = create(
        :user,
        active: false,
        deactivated_at: Time.current
      )

      user.activate!

      expect(user.reload).to be_active
    end

    it "clears the deactivation timestamp" do
      user = create(
        :user,
        active: false,
        deactivated_at: Time.current
      )

      user.activate!

      expect(user.reload.deactivated_at).to be_nil
    end
  end

  describe "#active_for_authentication?" do
    it "allows an active user to authenticate" do
      user = build(:user, active: true)

      expect(user.active_for_authentication?).to be(true)
    end

    it "does not allow an inactive user to authenticate" do
      user = build(:user, active: false)

      expect(user.active_for_authentication?).to be(false)
    end
  end

  describe "#inactive_message" do
    it "returns deactivated for an inactive user" do
      user = build(:user, active: false)

      expect(user.inactive_message).to eq(:deactivated)
    end
  end
end