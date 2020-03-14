class VotesController < ApplicationController
  before_action :reject_unless_user_logged_in
  before_action :set_votable, only: :create
  before_action :correct_user, only: %i[destroy update]

  def create
    vote = @votable.votes.build(vote_params)
    flash[:warning] = vote.errors.full_messages unless vote.save
    redirect_to post_path(@post)
  end

  def update
    vote.up = !vote.up
    vote.save
    redirect_to post_path(vote.post)
  end

  def destroy
    vote.destroy
    redirect_to post_path(vote.post)
  end

  private

  def vote_params
    @vote_params ||= params.require(:vote).permit(:up)
                           .merge(user_id: current_user.id)
  end

  def set_votable
    if (id = params[:post_id])
      @post = @votable = Post.find_by(id: id)
    elsif (id = params[:comment_id])
      @votable = Comment.includes(:post).find_by(id: id)
      @post = @votable.post
    end
    return if @votable

    flash[:error] = "We couldn't find the thing you're voting on."
    redirect_to root_path
  end

  # Tests whether the user trying to interact with the comment is its author
  def correct_user
    super(vote&.user_id)
  end

  def vote
    @vote ||= Vote.includes(:votable).find_by(id: params[:id])
  end
end
