class CommentsController < ApplicationController
  include ApplicationHelper
  before_action :logged_in_user
  before_action :set_post, only: :create
  before_action :correct_user, only: %i[destroy]
  def create
    @comment = @post.comments.build(comment_params)
    @comment = Comment.new if @comment.save
    @comments = @post.comments.send(params[:order] || :recent)
    render 'posts/show'
  end

  def destroy
    post_id = comment.post_id
    comment.safe_delete
    flash[:success] = 'Comment deleted'
    redirect_to post_path(post_id)
  end

  private

  def comment
    @comment ||= Comment.find_by(id: params[:id])
  end

  def comment_params
    @comment_params ||= params.require(:comment).permit(:text, :post_id)
                              .merge(user_id: current_user.id)
  end

  # Before filters
  def set_post
    return if (@post = Post.find_by(id: params[:post_id]))

    flash[:error] = 'Post not found'
    redirect_to root_path
  end

  # Tests whether the user trying to interact with the comment is its author
  def correct_user
    super(comment&.user_id)
  end
end
