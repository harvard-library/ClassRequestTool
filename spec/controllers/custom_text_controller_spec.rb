require 'rails_helper'

describe Admin::CustomTextsController do

  
  describe "#index" do
    
    it "renders the index template for a superadmin" do
      login_with create(:user, :superadmin)
      get :index
      expect(response).to render_template(:index)
    end

    it "doesn't render the index template for a non-superadmin" do
      login_with create(:user)
      get :index
      expect(response).not_to render_template(:index)
    end
  end

end
