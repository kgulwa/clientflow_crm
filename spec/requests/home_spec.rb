require "rails_helper"

RSpec.describe "Home", type: :request do
  describe "GET /" do
    context "when the user is signed in" do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it "returns a successful response" do
        get root_path

        expect(response).to have_http_status(:success)
      end

      it "displays the user's first name" do
        get root_path

        expect(response.body).to include(user.first_name)
      end
    end

    context "when the user is not signed in" do
      it "redirects to the sign-in page" do
        get root_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end