class PassagesController < ApplicationController
  before_action :set_passage

  def complete
    typing_session = @passage.typing_sessions.build(typing_session_params)

    if typing_session.save
      render json: { success: true }
    else
      render json: {
        success: false,
        errors: typing_session.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def jump
    book = @passage.book

    # Mark all passages before this one as skipped (create empty typing sessions)
    passages_to_skip = book.passages.where("id < ?", @passage.id).where.not(
      id: TypingSession.select(:passage_id)
    )

    passages_to_skip.find_each do |passage|
      passage.typing_sessions.create!(wpm: 0, accuracy: 0, duration_seconds: 0)
    end

    redirect_to practice_book_path(book)
  end

  private

  def set_passage
    @passage = Passage.find(params[:id])
  end

  def typing_session_params
    params.require(:typing_session).permit(:wpm, :accuracy, :duration_seconds)
  end
end
