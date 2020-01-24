class StaticPagesController < ApplicationController
  def home
    @posts = Post.send(params[:order] || :recent).page(params[:page])
  end

  def about
  end

  def contact
  end

  def help
  end
end
