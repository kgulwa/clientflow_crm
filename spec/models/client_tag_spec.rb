# frozen_string_literal: true

require "rails_helper"

RSpec.describe ClientTag, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:client) }
    it { is_expected.to belong_to(:tag) }
  end

  describe "validations" do
    it "allows a tag belonging to the client's workspace" do
      user = create(:user)
      client = create(
        :client,
        user: user,
        workspace: user.workspace
      )
      tag = create(
        :tag,
        user: user,
        workspace: user.workspace
      )

      client_tag = build(
        :client_tag,
        client: client,
        tag: tag
      )

      expect(client_tag).to be_valid
    end

    it "allows another user's tag from the same workspace" do
      workspace = create(:workspace)
      client_owner = create(
        :user,
        workspace: workspace
      )
      tag_owner = create(
        :user,
        workspace: workspace
      )

      client = create(
        :client,
        user: client_owner,
        workspace: workspace
      )

      tag = create(
        :tag,
        user: tag_owner,
        workspace: workspace
      )

      client_tag = build(
        :client_tag,
        client: client,
        tag: tag
      )

      expect(client_tag).to be_valid
    end

    it "does not allow the same tag to be assigned twice" do
      user = create(:user)
      client = create(
        :client,
        user: user,
        workspace: user.workspace
      )
      tag = create(
        :tag,
        user: user,
        workspace: user.workspace
      )

      create(
        :client_tag,
        client: client,
        tag: tag
      )

      duplicate_client_tag = build(
        :client_tag,
        client: client,
        tag: tag
      )

      expect(duplicate_client_tag).not_to be_valid
      expect(duplicate_client_tag.errors[:tag_id])
        .to include("has already been assigned to this client")
    end

    it "does not allow a tag from another workspace to be assigned" do
      client_owner = create(:user)
      tag_owner = create(:user)

      client = create(
        :client,
        user: client_owner,
        workspace: client_owner.workspace
      )

      tag = create(
        :tag,
        user: tag_owner,
        workspace: tag_owner.workspace
      )

      client_tag = build(
        :client_tag,
        client: client,
        tag: tag
      )

      expect(client_tag).not_to be_valid
      expect(client_tag.errors[:tag])
        .to include("must belong to the same workspace as the client")
    end
  end
end