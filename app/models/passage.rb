class Passage < ApplicationRecord
  belongs_to :chapter
  has_one :book, through: :chapter
  has_many :typing_sessions, dependent: :destroy

  validates :content, presence: true
  validates :position, presence: true

  scope :search, ->(query) { where("content ILIKE ?", "%#{query}%") }

  before_save :calculate_word_count

  def completed?
    typing_sessions.exists?
  end

  def best_session
    typing_sessions.order(wpm: :desc).first
  end

  def next_passage
    # First try next passage in same chapter
    same_chapter_next = chapter.passages.where("position > ?", position).order(:position).first
    return same_chapter_next if same_chapter_next

    # Otherwise, first passage of next chapter
    next_chapter = book.chapters.where("position > ?", chapter.position).order(:position).first
    next_chapter&.passages&.order(:position)&.first
  end

  def previous_passage
    # First try previous passage in same chapter
    same_chapter_prev = chapter.passages.where("position < ?", position).reorder(position: :desc).first
    return same_chapter_prev if same_chapter_prev

    # Otherwise, last passage of previous chapter
    prev_chapter = book.chapters.where("position < ?", chapter.position).order(position: :desc).first
    prev_chapter&.passages&.reorder(position: :desc)&.first
  end

  private

  def calculate_word_count
    self.word_count = content.to_s.split(/\s+/).count
  end
end
