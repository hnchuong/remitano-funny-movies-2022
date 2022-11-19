class MovieController < ApplicationController
  before_action :authenticate_user!
  before_action :find_movie, only: %w(vote)

  def index
  end

  def new
  end

  def share
    movie = Movie.new(movie_params)
    movie.author = current_user

    if movie.save
      return response_json(200, 'success', Movie.response_json(movie).to_json)
    else
      return response_json(406, movie.errors.full_messages)
    end
  end

  def vote
    return response_json(404, 'Movie not found') if vote_params[:id].empty?

    vote = Movie.vote(@movie, current_user, vote_params[:type])
    if vote
      return response_json(200, 'success', @movie)
    else
      return response_json(200, vote.errors.full_messages)
    end
  end

  private
  def movie_params
    params.require(:movie).permit(:youtube_id, :title, :description)
  end

  def vote_params
    params.require(:movie).permit(:id, :type)
  end

  def find_movie
    @movie = Movie.find(vote_params[:id]) unless vote_params[:id].empty?
  rescue => e
    return response_json(404, e.message)
  end

  def response_json(code, mess, data = {})
    render json: {
      statusCode: code,
      message: mess,
      movie: data
    }, status: code
    return
  end
end
