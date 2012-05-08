require 'spec_helper'

describe Micropost do

  before(:each) do
    @user = Factory(:user)
    @attr = { :description => "Micropost description content",
	      :score => 5 }
  end

  it "should create a new instance given valid attributes" do
    @user.microposts.create!(@attr)
  end

  describe "user associations" do

    before(:each) do
      @micropost = @user.microposts.create(@attr)
    end

    it "should have a user attribute" do
      @micropost.should respond_to(:user)
    end

    it "should have the correct associated user" do
      @micropost.user_id.should == @user.id
      @micropost.user.should == @user
    end

  end  # describe "user associations" do

  describe "score associations" do

    before(:each) do
      @micropost = @user.microposts.create(@attr)
    end

    it "should have the correct score" do
      @micropost.score.should == 5
    end

  end  # describe "score associations" do

  describe "validations" do

    it "should require a user id" do
      Micropost.new(@attr).should_not be_valid
    end

    it "should allow for normal micropost content" do
      @user.microposts.build(:description => "Sample action here", :score => 4).should be_valid
    end

    it "should require a description" do
      @user.microposts.build(:description => nil, :score => 4).should_not be_valid
    end

    it "should require non-blank description" do
      @user.microposts.build(:description => "  ", :score => 4).should_not be_valid
    end

    it "should reject descriptions over 140 characters" do
      @user.microposts.build(:description => "a" * 141, :score => 3).should_not be_valid
    end

  end  # describe "validations" do

end  # describe Micropost do
