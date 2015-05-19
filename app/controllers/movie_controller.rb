class MovieController < ApplicationController 
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index
  end

  def show
    @movie = Movie.find(params[:id])
    render layout: 'simple2'
  end

end
