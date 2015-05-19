class UserController < ApplicationController 
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index
    @users = User.all.paginate(:page => params[:page], :per_page => 28)
  end

  def show
    @user = User.find(params[:id])
    path = 'http://maps.sibcolombia.net/'
    @ratings = JSON.parse(Net::HTTP.get(URI.parse(path+"ratings/user/#{@user.id}")))['hits']['hits']
    @tags = JSON.parse(Net::HTTP.get(URI.parse(path+"tag/user/#{@user.id}")))['hits']['hits']

    @collaborative = JSON.parse(Net::HTTP.get(URI.parse(path+"recommendatorcf/user/#{@user.id}")))
    @onto = JSON.parse(Net::HTTP.get(URI.parse(path+"recommendatorcontenthibrid/user/#{@user.id}")))
    @hibrid = JSON.parse(Net::HTTP.get(URI.parse(path+"recommendatorfullhibrid/user/#{@user.id}")))

    @limit = 5
    @limit = params[:neigborhood].to_i if params[:neigborhood]

    render layout: 'simple'
  end
end