class PagesController < ApplicationController

  def home
    @title = "Home"
    if signed_in?
      @micropost = Micropost.new
      @feed_items = current_user.feed.paginate(:page => params[:page])
      # TODO make sure this is working
      #@possible_actions = [
#			   ['I didn\'t buy breakfast today (5 pts)','breakfast:5'],
#			   ['I didn\'t buy lunch today (6 pts)','lunch:6'],
#			   ['I carpooled today (7 pts)','carpool:7']
#                          ]
    end
  end

  def contact
    @title = "Contact"
  end

  def about
    @title = "About"
  end

  def help
    @title = "Help"
  end

  def blog
    @title = "Blog"
  end

end
