require 'spec_helper'

describe ApplicationsController do
  include AuthHelper

  describe 'GET new' do
    it 'should redirect to root if not logged in' do
      get :new
      response.should redirect_to :root
    end

    it 'should redirect to root if logged in as visitor' do
      login_as(:visitor)
      get :new
      response.should redirect_to :root
    end

    it 'should redirect to edit if logged in as applicant' do
      user = login_as(:applicant)
      get :new
      response.should redirect_to edit_application_path(user.application)
    end

    it 'should redirect to root if logged in as member' do
      login_as(:member)
      get :new
      response.should redirect_to :root
    end
  end

  describe 'GET show' do
    it 'should redirect to root if not logged in' do
      get :show, id: 1
      response.should redirect_to :root
    end

    it 'should redirect to root if logged in as visitor' do
      user = login_as(:visitor)
      get :show, id: user.application.id
      response.should redirect_to :root
    end

    it 'should redirect to root if logged in as member' do
      user = login_as(:member)
      get :show, id: user.application.id
      response.should redirect_to :root
    end

    describe 'if logged in as applicant' do
      let(:user) { create :applicant }
      let(:other_user) { create :applicant }

      before { log_in(user) }

      it 'should render own application' do
        get :show, id: user.application.id
        response.should render_template :show
      end

      it 'should not render application of another user' do
        get :show, id: other_user.application.id
        response.should redirect_to :root
      end
    end
  end

  describe 'GET edit' do
    it 'should redirect to root if not logged in' do
      get :edit, id: User.make!(:applicant).application.id
      response.should redirect_to :root
    end

    it 'should redirect to root if logged in as visitor' do
      user = login_as(:visitor)
      get :edit, id: user.application.id
      response.should redirect_to :root
    end

    it 'should redirect to root if logged in as member' do
      user = login_as(:member)
      get :edit, id: user.application.id
      response.should redirect_to :root
    end

    describe 'if logged in as applicant' do
      let(:user) { create :applicant }
      let(:other_user) { create :applicant }

      before { log_in(user) }

      it 'should render edit for own application' do
        get :edit, id: user.application.id
        response.should render_template :edit
      end

      it "should redirect to root for another user's application" do
        get :edit, id: other_user.application.id
        response.should redirect_to :root
      end
    end
  end

  describe 'POST update' do
    it 'should redirect to root if not logged in' do
      post :update, id: User.make!(:applicant).application.id
      response.should redirect_to :root
    end

    it 'should redirect to root if logged in as visitor' do
      user = login_as(:visitor)
      post :update, id: user.application.id
      response.should redirect_to :root
    end

    it 'should redirect to root if logged in as member' do
      user = login_as(:member)
      post :update, id: user.application.id
      response.should redirect_to :root
    end

    describe 'if logged in as applicant' do
      it 'should update own application' do
        user = login_as(:applicant)
        user.application.agreement_terms.should be_false

        params = { id: user.application.id, user: {
          application_attributes:
            { id: user.application.id, agreement_terms: true }
          }
        }

        post :update, params

        response.should redirect_to edit_application_path(user.application)

        user.application.agreement_terms.should be_true
      end
    end
  end
end
