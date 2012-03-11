class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    #set up checked ratings
    @checked_ratings_hash = {}
    if params[:ratings]
      @checked_ratings_hash = params[:ratings]
    end
 
    condition_hash = {}
    if !@checked_ratings_hash.empty?
      condition_hash[:conditions] = ["rating in (?)", @checked_ratings_hash.keys]
    end
    
    if params[:sort] == "title"
      condition_hash[:order] = "title ASC"
      @sort = "title"
    elsif params[:sort] == "release_date"
      condition_hash[:order] = "release_date ASC"
      @sort = "release_date"
    end
    
    @movies = Movie.find(:all, condition_hash)
    
    #set up all ratings
    @all_ratings = []
    Movie.select(:rating).each{|x| @all_ratings << x.rating}
    @all_ratings = @all_ratings.uniq.sort
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
