class CommentsController < ApplicationController
  include ApplicationHelper
  before_action :logged_in_user
  before_action :set_post_if_exists
  def create
    @comment = Comment.new(post_params.merge(user_id: current_user.id))
    @comment = Comment.new if @comment.save
    @comments = @post.comments.send(params[:order] || :recent)
    render 'posts/show'
  end

  private

  def post_params
    @post_params ||= params.require(:comment).permit(:text, :post_id)
  end

  # Before filters
  def set_post_if_exists
    return if (@post = Post.find_by(id: post_params[:post_id]))

    flash[:error] = 'Post not found'
    redirect_to root_path
  end
end
