require 'spec_helper'

describe "LayoutLinks" do

  it "should have a Home page at '/" do
    get '/'
    response.should have_selector('title', :content => "Home")
  end

  it "should have a Contact page at '/contact" do
    get '/contact'
    response.should have_selector('title', :content => "Contact")
  end

  it "should have an About page '/about" do
    get '/about'
    response.should have_selector('title', :content => "About")
  end

  it "should have a signup page at '/signup" do
    get '/signup'
    response.should have_selector('title', :content => "Sign up")
  end

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    response.should have_selector('title', :content => "About")
    click_link "Contact"
    response.should have_selector('title', :content => "Contact")
    click_link "Blog"
    response.should have_selector('title', :content => "Blog")
    click_link "Home"
    response.should have_selector('title', :content => "Home")
  end

  describe "when not signed in" do
    it "should have a signin link" do
      visit root_path
      response.should have_selector("a", :href => signin_path,
					 :content => "Sign in")
    end

  end

  describe "when signed in" do

    before(:each) do
      @user = Factory(:user)
      integration_sign_in(@user)
    end

    it "should have a signout link" do
      visit root_path
      response.should have_selector("a", :href => signout_path,
					 :content => "Sign out")
    end

  end  # describe "when signed in" do

end  # describe "LayoutLinks" do
