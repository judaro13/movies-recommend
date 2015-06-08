class UserController < ApplicationController 
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  after_filter :set_request_path, :set_ratings, :set_filters

  def index
    @users = User.all.paginate(:page => params[:page], :per_page => 28)
  end

  def show
    @user = User.find(params[:id])

    @limit = 5
    @limit = params[:neigborhood].to_i if params[:neigborhood]

    render layout: 'simple'
  end

  def set_request_path
    path = 'http://maps.sibcolombia.net/'
  end

  def set_ratings
    @ratings = URI.parse(path+"ratings/user/#{@user.id}")
    @ratings = request_and_parse(@ratings)
    @ratings = @ratings['hits']['hits']

    @tags = URI.parse(path+"tag/user/#{@user.id}")
    @tags = request_and_parse(@tags)
    @tags = @tags['hits']['hits']  
  end

  def set_filters
    @collaborative = URI.parse(path+"recommendatorcf/user/#{@user.id}")
    @collaborative = request_and_parse(@collaborative)

    @onto = URI.parse(path+"recommendatorcontenthibrid/user/#{@user.id}") #ontologic filter
    @onto = request_and_parse(@onto)

    @hibrid = URI.parse(path+"recommendatorfullhibrid/user/#{@user.id}")
    @hibrid = request_and_parse(@hibrid)
  end

  def request_and_parse(value)
    value = Net::HTTP.get(value)
    JSON.parse(value)
  end
end