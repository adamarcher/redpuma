require 'spec_helper'

describe MicropostsController do
  render_views

  describe "access control" do

    it "should deny access to 'create'" do
      post :create
      response.should redirect_to(signin_path)
    end

    it "should deny access to 'destroy'" do
      delete :destroy, :id => 1
      response.should redirect_to(signin_path)
    end

  end  # describe "access control" do

  describe "POST 'create'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
    end

    describe "failure" do

      before(:each) do
	@attr = { :description => "" }
      end

      it "should not create a micropost" do
	lambda do
	  post :create, :micropost => @attr
	end.should_not change(Micropost, :count)
      end

      it "should render the home page" do
	post :create, :micropost => @attr
	response.should render_template('pages/home')
      end

    end  # describe "failure" do

    describe "success" do

      before(:each) do
        @attr = { :description => "Lorem ipsum", :score => 6 }
      end

      it "should create a micropost" do
	lambda do
	  post :create, :micropost => @attr
	end.should change(Micropost, :count).by(1)
      end

      it "should redirect to the home page" do
	post :create, :micropost => @attr
	response.should redirect_to(root_path)
      end

      it "should have a flash message" do
	post :create, :micropost => @attr
	flash[:success].should =~ /!.*!/i
      end

    end  # describe "success" do

  end  # describe "POST 'create'" do

  describe "DELETE 'destroy'" do

    describe "for an unauthorized user" do

      before(:each) do
	@user = Factory(:user)
	wrong_user = Factory(:user, :email => Factory.next(:email))
	test_sign_in(wrong_user)
	@micropost = Factory(:micropost, :user => @user)
      end

      it "should deny access" do
	delete :destroy, :id => @micropost
	response.should redirect_to(root_path)
      end
    end

    describe "for an authorized user" do

      before(:each) do
	@user = test_sign_in(Factory(:user))
	@micropost = Factory(:micropost, :user => @user)
      end

      it "should destroy the micropost" do
	lambda do
	  delete :destroy, :id => @micropost
	end.should change(Micropost, :count).by(-1)
      end

    end  # describe "for an authorized user" do

  end  # describe "DELETE 'destroy'" do

end  # describe MicropostsController do 
