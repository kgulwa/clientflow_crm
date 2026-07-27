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
end