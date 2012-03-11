class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def new_request?(params)
    if !params[:ratings] && !params[:sort]
      return true
    end
    return false
  end
  
  def redirect?(params)
    if new_request?(params) && ((session[:ratings] && !session[:ratings].empty?) || (session[:sort] && !session[:sort].empty?))
      return true
    end
    return false
  end
  
  def index
    if redirect?(params)
      redirect_to movies_path :sort=>session[:sort], :ratings=>session[:ratings]
    end
    
    #set up checked ratings
    @checked_ratings_hash = {}
    condition_hash = {}
    
    if params[:ratings]
      @checked_ratings_hash = params[:ratings]
    elsif new_request?(params) && session[:ratings]
      @checked_ratings_hash = session[:ratings]
    end
    
    if !@checked_ratings_hash.empty?
      condition_hash[:conditions] = ["rating in (?)", @checked_ratings_hash.keys]
    end
    
    if params[:sort] && ["title","release_date"].include?(params[:sort])
      condition_hash[:order] = params[:sort]+" ASC"
      @sort = params[:sort]
    elsif new_request?(params) && session[:sort] && !session[:sort].empty?
      condition_hash[:order] = session[:sort]+" ASC"
      @sort = session[:sort]
    end
    
    @movies = Movie.find(:all, condition_hash)
    
    #set up all ratings
    @all_ratings = []
    Movie.select(:rating).each{|x| @all_ratings << x.rating}
    @all_ratings = @all_ratings.uniq.sort
    
    if !new_request?(params)
      session[:ratings] = @checked_ratings_hash
      session[:sort] = @sort
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
