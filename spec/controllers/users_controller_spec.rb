require 'spec_helper'

describe UsersController do
  render_views

  # Test for GETting the user index page
  describe "GET 'index'" do

    describe "for non-signed-in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
	flash[:notice].should =~ /sign in/i
      end
    end

    describe "for signed-in users" do

      before(:each) do
        @user = test_sign_in(Factory(:user))
        second = Factory(:user, :email => "another@example.com")
        third  = Factory(:user, :email => "another@example.net")

	@users = [@user, second, third]
	30.times do
	  @users << Factory(:user, :email => Factory.next(:email))
	end
      end

      it "should be successful" do
        get :index
        response.should be_success
      end

      it "should have the correct title" do
        get :index
        response.should have_selector("title", :content => "All users")
      end

      it "should have an element for each user" do
        get :index
        @users.each do |user|
          response.should have_selector("a", :content => user.name)
        end
      end

      it "should not display a 'delete' link for users" do
        get :index
        @users.each do |user|
          response.should_not have_selector("a", :title => "Delete #{@user.name}",
						 :content => "delete")
        end
      end

      it "should paginate users" do
	get :index
	response.should have_selector("div.pagination")
	response.should have_selector("span.disabled", :content => "Previous")
	response.should have_selector("a", :href => "/users?page=2",
					   :content => "2")
	response.should have_selector("a", :href => "/users?page=2",
					   :content => "Next")
      end

    end  # describe "for signed-in users" do

  end  # describe "GET 'index'" do

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

    it "should show the user's microposts" do
      mp1 = Factory(:micropost, :user => @user,
				:description=> "Description for mp1",
				:score => 3)
      mp2 = Factory(:micropost, :user => @user,
				:description=> "Description for mp2",
				:score => 4)
      get :show, :id => @user
      response.should have_selector("span", :class => "description", :content => mp1.description)
      response.should have_selector("span", :class => "description", :content => mp2.description)
      response.should have_selector("span", :class => "score", :content => mp1.score.to_s)
      response.should have_selector("span", :class => "score", :content => mp2.score.to_s)
    end

  end  # describe "GET 'show'" do


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

      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end

      it "should have a welcome flash message" do
        post :create, :user => @attr
	flash[:success].should =~ /Welcome to RedPuma!/i
      end

    end  # describe "success" do

  end  # describe "POST 'create'" do

  describe "GET 'edit'" do

    before (:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end

    it "should have the correct title" do
      get :edit, :id => @user
      response.should have_selector("title", :content => "Edit user")
    end

    it "should have a link to change the Gravatar" do
      get :edit, :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravatar_url,
					 :target => "_blank", :content => "change")
    end

  end  # describe "GET 'edit'" do

  describe "PUT 'update'" do

    before (:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    describe "failure" do

      # All the fields in the form are blank
      before(:each) do
        @attr = { :name => "", :email => "", :password => "",
		  :password_confirmation => "" }
      end

      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end

      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector("title", :content => "Edit user")
      end

    end  # describe "failure" do

    describe "success" do

      before(:each) do
        @attr = { :name => "New Name", :email => "user@example.org",
		  :password => "blahblah", :password_confirmation => "blahblah" }
      end

      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should == @attr[:name]
	@user.email.should == @attr[:email]
      end

      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end

      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end

    end  # describe "success" do

  end  # describe "PUT 'update'" do

  describe "authentication of edit/update pages" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "for non-signed in users" do

      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end

    end

    describe "for signed-in users" do

      before(:each) do
        wrong_user = Factory(:user, :email => "user@example.net")
        test_sign_in(wrong_user)
      end

      it "should require matching users for 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end

      it "should require matching users for 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end

    end  # describe "for signed-in users" do

  end  # describe "authentication of edit/update pages" do

  describe "DELETE 'destroy'" do

    before(:each) do
      @user = Factory(:user)
    end


    describe "as a non-signed-in user" do
      it "should deny access" do
	delete :destroy, :id => @user
	response.should redirect_to(signin_path)
      end
    end

    describe "as a non-admin user" do
      it "should protect the page" do
	test_sign_in(@user)
	delete :destroy, :id => @user
	response.should redirect_to(root_path)
      end
    end

    describe "as an admin user" do

      before(:each) do
        @admin = Factory(:user, :email => "admin@redpuma.com", :admin => true)
	test_sign_in(@admin)
      end

      # We could test for (and implement) this in the future
      # it "should not display a 'delete' link for admins" do
        # get :index
        # response.should_not have_selector("a", :title => "Delete #{@admin.name}", :content => "delete")
      # end

      it "should display 'delete' link for normal users" do
        get :index
        response.should have_selector("a", :title => "Delete #{@user.name}", :content => "delete")
      end

      it "should destroy the user" do
        lambda do
	  delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it "should not be able to destroy an admin user" do
        lambda do
	  delete :destroy, :id => @admin
	  flash[:notice].should =~ /You're not allowed to delete an admin/i
        end.should_not change(User, :count).by(-1)
      end
    
      it "should redirect to the users page" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end

      it "should display the correct flash message" do
        delete :destroy, :id => @user
	flash[:success].should =~ /user deleted/i
      end

    end  # describe "as an admin user" do

  end  # describe "DELETE 'destroy'" do

end  # describe UsersController do
