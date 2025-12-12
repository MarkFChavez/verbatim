class Book < ApplicationRecord
  belongs_to :user

  has_many :chapters, -> { order(:position) }, dependent: :destroy
  has_many :passages, through: :chapters
  has_many :typing_sessions, through: :passages

  has_one_attached :cover_image
  has_one_attached :epub_file

  validates :title, presence: true

  def progress_percentage
    return 0 if passages.empty?

    completed_passages = passages.joins(:typing_sessions).distinct.count
    (completed_passages.to_f / passages.count * 100).round(2)
  end

  def completed?
    passages.any? && progress_percentage == 100
  end

  def current_passage
    passages
      .left_joins(:typing_sessions)
      .where(typing_sessions: { id: nil })
      .order("chapters.position", :position)
      .first || passages.order("chapters.position", :position).first
  end

  def total_words
    passages.sum(:word_count)
  end

  def average_wpm
    TypingSession.joins(passage: :chapter)
      .where(chapters: { book_id: id })
      .where("wpm > 0")
      .average(:wpm)&.round || 0
  end

  def average_accuracy
    TypingSession.joins(passage: :chapter)
      .where(chapters: { book_id: id })
      .where("wpm > 0")
      .average(:accuracy)&.round || 0
  end
end
