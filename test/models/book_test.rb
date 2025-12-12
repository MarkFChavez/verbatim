require "test_helper"

class BookTest < ActiveSupport::TestCase
  # Validations
  test "should be valid with valid attributes" do
    book = Book.new(title: "Test Book", user: users(:alice))
    assert book.valid?
  end

  test "should require title" do
    book = Book.new(user: users(:alice))
    assert_not book.valid?
    assert_includes book.errors[:title], "can't be blank"
  end

  test "should require user" do
    book = Book.new(title: "Test Book")
    assert_not book.valid?
    assert_includes book.errors[:user], "must exist"
  end

  # Associations
  test "should belong to user" do
    book = books(:great_gatsby)
    assert_equal users(:alice), book.user
  end

  test "should have many chapters" do
    book = books(:great_gatsby)
    assert_respond_to book, :chapters
    assert book.chapters.count >= 2
  end

  test "should have many passages through chapters" do
    book = books(:great_gatsby)
    assert_respond_to book, :passages
    assert book.passages.count >= 2
  end

  test "should have many typing_sessions through passages" do
    book = books(:great_gatsby)
    assert_respond_to book, :typing_sessions
  end

  test "should destroy associated chapters when destroyed" do
    book = books(:great_gatsby)
    chapter_count = book.chapters.count
    assert chapter_count > 0

    assert_difference "Chapter.count", -chapter_count do
      book.destroy
    end
  end

  # Methods
  test "progress_percentage returns 0 for book with no passages" do
    book = books(:empty_book)
    assert_equal 0, book.progress_percentage
  end

  test "progress_percentage calculates correctly" do
    book = books(:great_gatsby)
    # gatsby_passage_one and gatsby_passage_two have typing sessions
    # gatsby_passage_three does not
    total_passages = book.passages.count
    completed_passages = book.passages.joins(:typing_sessions).distinct.count
    expected = (completed_passages.to_f / total_passages * 100).round(2)

    assert_equal expected, book.progress_percentage
  end

  test "current_passage returns first uncompleted passage" do
    book = books(:great_gatsby)
    current = book.current_passage

    # Should return a passage without typing sessions
    # or the first passage if all are completed
    assert_not_nil current
    assert_kind_of Passage, current
  end

  test "current_passage returns first passage when all completed" do
    book = books(:moby_dick)
    # No typing sessions for moby_dick passages
    current = book.current_passage

    assert_equal passages(:moby_passage_one), current
  end

  test "total_words sums word counts of all passages" do
    book = books(:great_gatsby)
    expected_total = book.passages.sum(:word_count)

    assert_equal expected_total, book.total_words
  end

  test "total_words returns 0 for book with no passages" do
    book = books(:empty_book)
    assert_equal 0, book.total_words
  end
end
