class PassagesController < ApplicationController
  before_action :set_passage

  def show
    @book = @passage.book
    @chapter = @passage.chapter
  end

  def complete
    typing_session = @passage.typing_sessions.build(typing_session_params)

    if typing_session.save
      next_passage = @passage.next_passage

      render json: {
        success: true,
        next_passage_url: next_passage ? passage_path(next_passage) : book_path(@passage.book),
        has_next: next_passage.present?
      }
    else
      render json: {
        success: false,
        errors: typing_session.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_passage
    @passage = Passage.find(params[:id])
  end

  def typing_session_params
    params.require(:typing_session).permit(:wpm, :accuracy, :duration_seconds)
  end
end
