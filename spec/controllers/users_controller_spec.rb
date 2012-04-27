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
      get :new
      response.should be_success
    end

    it "shound have the right title" do
      get :new
      response.should have_selector("title", :content => "Sign up")
    end 

    it "should have a name field" do
      get :new
      response.should have_selector("input[name='user[name]'][type='text']")
    end

    it "should have an email field" do
      get :new
      response.should have_selector("input[name='user[email]'][type='text']")
    end

    it "should have a password field" do
      get :new
      response.should have_selector("input[name='user[password]'][type='password']")
    end

    it "should have a 'confirm password' field" do
      get :new
      response.should have_selector("input[name='user[password_confirmation]'][type='password']")
    end


  end # describe "GET 'new'" do

  describe "POST 'create'" do

    # Visit the sign up page, and click 'submit' without filling
    # in any fields
    describe "failure" do

      # All the fields in the form are blank
      before(:each) do
        @attr = { :name => "", :email => "", :password => "",
		  :password_confirmation => "" }
      end

      it "should not create a user if all the fields are blank" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end

      it "should have the correct title" do
        post :create, :user => @attr
        response.should have_selector("title", :content => "Sign up")
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end

    end  # describe "failure" do


    # Now test the successful signup scenario
    describe "success" do

      before(:each) do
        @attr = { :name => "New User", :email => "user@example.com",
		  :password => "hellodolly",
		   :password_confirmation => "hellodolly" }
      end

      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it "should redirect the user to the user show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end

      it "should have a welcome flash message" do
        post :create, :user => @attr
	flash[:success].should =~ /Welcome to RedPuma!/i
      end

    end  # describe "success" do

  end  # describe "POST 'create'" do

end  # describe UsersController do
