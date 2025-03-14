class CommentsController < ApplicationController
    before_action :authenticate_request

      # ✅ Get All Comments for a Post
  def index
    post = Post.find_by(id: params[:post_id])
    if post
      comments = post.comments.order(created_at: :asc)
      render json: comments, status: :ok
    else
      render json: { error: "Post not found" }, status: :not_found
    end
  end
  
    # ✅ Create a Comment
    def create
      post = Post.find_by(id: params[:post_id])
      return render json: { error: "Post not found" }, status: :not_found unless post
  
      comment = post.comments.build(text: comment_params[:text], user_id: @current_user.id)

  
      if comment.save
        render json: comment, status: :created
      else
        render json: { error: comment.errors.full_messages }, status: :unprocessable_entity
      end
    end

      # ✅ Update Comment
  def update
    comment = Comment.find_by(id: params[:id])

    if comment.nil?
      return render json: { error: "Comment not found" }, status: :not_found
    end

    if comment.update(comment_params)
      render json: comment, status: :ok
    else
      render json: { error: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # ✅ Delete Comment
  def destroy
    comment = Comment.find_by(id: params[:id])

    if comment.nil?
      return render json: { error: "Comment not found" }, status: :not_found
    end

    # ✅ Ensure only the comment owner can delete
    if comment.user_id != @current_user.id
      return render json: { error: "Unauthorized: You can only delete your own comments" }, status: :forbidden
    end

    if comment.destroy
      render json: { message: "Comment deleted successfully" }, status: :ok
    else
      render json: { error: "Unable to delete comment" }, status: :unprocessable_entity
    end
  end
  
    private
  
    # ✅ Strong Parameters
    def comment_params
      params.require(:comment).permit(:text)
    end
  end
  