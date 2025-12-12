require "test_helper"

class StagedBookTest < ActiveSupport::TestCase
  # Validations
  test "should be valid with valid attributes" do
    staged_book = StagedBook.new(
      user: users(:alice),
      title: "Test Staged Book",
      author: "Test Author",
      chapters_data: []
    )
    assert staged_book.valid?
  end

  test "should require title" do
    staged_book = StagedBook.new(user: users(:alice), author: "Test Author")
    assert_not staged_book.valid?
    assert_includes staged_book.errors[:title], "can't be blank"
  end

  test "should require user" do
    staged_book = StagedBook.new(title: "Test Book", author: "Test Author")
    assert_not staged_book.valid?
    assert_includes staged_book.errors[:user], "must exist"
  end

  test "author is optional" do
    staged_book = StagedBook.new(user: users(:alice), title: "Test Book")
    assert staged_book.valid?
  end

  # Associations
  test "should belong to user" do
    staged_book = staged_books(:staged_gatsby)
    assert_equal users(:alice), staged_book.user
  end

  test "should have cover_image attachment" do
    staged_book = staged_books(:staged_gatsby)
    assert_respond_to staged_book, :cover_image
  end

  test "should have epub_file attachment" do
    staged_book = staged_books(:staged_gatsby)
    assert_respond_to staged_book, :epub_file
  end

  # Methods
  test "included_chapters returns only chapters with included true" do
    staged_book = staged_books(:staged_gatsby)
    included = staged_book.included_chapters

    assert_equal 2, included.size
    assert included.all? { |ch| ch["included"] == true }
  end

  test "included_chapters returns empty array when chapters_data is nil" do
    staged_book = StagedBook.new(
      user: users(:alice),
      title: "Test",
      chapters_data: nil
    )

    assert_equal [], staged_book.included_chapters
  end

  test "included_chapters returns empty array when no chapters included" do
    staged_book = StagedBook.new(
      user: users(:alice),
      title: "Test",
      chapters_data: [
        { "title" => "Chapter 1", "content" => "Content", "included" => false }
      ]
    )

    assert_equal [], staged_book.included_chapters
  end

  test "total_word_count sums words in included chapters only" do
    staged_book = staged_books(:staged_gatsby)
    # Included chapters: "In my younger years." (4 words) + "About halfway between." (3 words)
    # Excluded chapter: "All rights reserved." (not counted)

    assert_equal 7, staged_book.total_word_count
  end

  test "total_word_count returns 0 when no chapters included" do
    staged_book = StagedBook.new(
      user: users(:alice),
      title: "Test",
      chapters_data: [
        { "title" => "Chapter 1", "content" => "Some content here", "included" => false }
      ]
    )

    assert_equal 0, staged_book.total_word_count
  end

  test "total_word_count returns 0 when chapters_data is empty" do
    staged_book = staged_books(:staged_empty)
    assert_equal 0, staged_book.total_word_count
  end

  test "total_word_count handles nil content gracefully" do
    staged_book = StagedBook.new(
      user: users(:alice),
      title: "Test",
      chapters_data: [
        { "title" => "Chapter 1", "content" => nil, "included" => true }
      ]
    )

    assert_equal 0, staged_book.total_word_count
  end
end
