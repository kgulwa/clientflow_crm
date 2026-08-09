require 'rails_helper'

RSpec.describe Workspace, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:users).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:clients).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:leads).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:tags).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    subject(:workspace) { build(:workspace) }

    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'deletion restrictions' do
    it 'cannot be destroyed while it has users' do
      workspace = create(:workspace)
      create(:user, workspace: workspace)

      expect(workspace.destroy).to be false
      expect(workspace.errors[:base]).to be_present
    end

    it 'can be destroyed when it has no associated records' do
      workspace = create(:workspace)

      expect do
        workspace.destroy
      end.to change(described_class, :count).by(-1)
    end
  end
end