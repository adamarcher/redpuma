require 'spec_helper'

describe UsersController do
  render_views

  # Test for GETting the user SHOW page, with a user factory
  describe "GET 'show'" do

    before(:each) do
      @user = Factory(:user)
    end

    # Verify that displaying the user from the DB works
    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end

    # Verify that we're displaying the correct user
    it "shound find the right user" do
      get :show, :id => @user
      # Now, verify that the variable recieved from the DB in the
      # action corresponds to the @user instance created by
      # Factory Girl.
      assigns(:user).should == @user
    end 

    it "should have the user's name in the user page title" do
      get:show, :id => @user
      response.should have_selector("title", :content => @user.name)
    end

    it "should have the user's name in the user page h1 tag" do
      get:show, :id => @user
      response.should have_selector("h1", :content => @user.name)
    end

    it "should have a profile image in the user page" do
      get:show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar")
    end
  end


  # Test for GETting a NEW page
  describe "GET 'new'" do

    it "should be successful" do
      get 'new'
      response.should be_success
    end

    it "shound have the right title" do
      get 'new'
      response.should have_selector("title", :content => "Sign up")
    end 
  end

end	 # describe UsersController do
