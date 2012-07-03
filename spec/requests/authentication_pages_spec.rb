require "spec_helper"

describe "Authentication" do
  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_selector("title", text: "Sign in") }
    it { should have_selector("h1",    text: "Sign in") }
  end

  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_selector("title", text: "Sign in") }
      it { should have_error_message("Invalid") }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector("div.alert.alert-error") }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { valid_signin(user) }

      it { should have_selector("title", text: "Accounts") }

      it { should have_link("Users",    href: users_path) }
      it { should have_link("Profile",  href: user_path(user)) }
      it { should have_link("Settings", href: edit_user_path(user)) }
      it { should have_link("Sign out", href: signout_path) }

      it { should_not have_link("Sign in", href: signin_path) }

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link("Sign in") }
      end
    end
  end

  describe "authorisation" do
    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do
          it "should render the desired protected page" do
            page.should have_selector("title", text: "Edit user")
          end
        end
      end

      describe "in the Users controller" do
        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_selector("title", text: "Sign in") }
        end

        describe "submitting to the update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(signin_path) }
        end

        describe "visiting the user index" do
          before { visit users_path }
          it { should have_selector("title", text: "Sign in") }
        end

        describe "visiting the profile page" do
          before { visit user_path(user) }
          it { should have_selector("title", text: "Sign in") }
        end
      end

      describe "in the Accounts controller" do
        describe "visiting the accounts index" do
          before { visit user_accounts_path(user) }
          it { should have_selector("title", text: "Sign in") }
        end

        describe "visiting the account page" do
          let(:account) { FactoryGirl.create(:account, user: user) }
          before { visit user_account_path(user, account) }

          it { should have_selector("title", text: "Sign in") }
        end
      end

      describe "in the Txns controller" do
        describe "submitting to the create action" do
          before { post txns_path }
          specify { response.should redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete txn_path(FactoryGirl.create(:txn)) }
          specify { response.should redirect_to(signin_path) }
        end
      end
    end

    describe "as wrong user" do
      let(:user)       { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user }

      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_selector("title", text: full_title("Edit user")) }
      end

      describe "submitting a PUT request to the Users#update action" do
        before { put user_path(wrong_user) }
        specify { response.should redirect_to(root_path) }
      end

      describe "in the Accounts controller" do
        describe "visiting the accounts index" do
          before { visit user_accounts_path(wrong_user) }
          it { should_not have_selector("title", text: full_title("Accounts")) }
        end

        describe "visiting the account page" do
          let(:wrong_account) { FactoryGirl.create(:account, user: wrong_user) }
          before { visit user_account_path(wrong_user, wrong_account) }

          it do
            should_not have_selector("title", text: full_title("Account with"))
          end
        end
      end
    end

    describe "as correct other_party in Accounts controller" do
      describe "visiting the account page" do
        let(:user)    { FactoryGirl.create(:user) }
        let(:account) { FactoryGirl.create(:account, other_party: user) }
        before do
          sign_in user
          visit user_account_path(user, account)
        end

        it do
          should have_selector("title",  text: full_title("Account with"))
        end
      end
    end
  end
end
