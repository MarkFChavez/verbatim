require "test_helper"

class ChapterTest < ActiveSupport::TestCase
  # Validations
  test "should be valid with valid attributes" do
    chapter = Chapter.new(book: books(:great_gatsby), title: "New Chapter", position: 3)
    assert chapter.valid?
  end

  test "should require position" do
    chapter = Chapter.new(book: books(:great_gatsby), title: "New Chapter")
    assert_not chapter.valid?
    assert_includes chapter.errors[:position], "can't be blank"
  end

  test "should require book" do
    chapter = Chapter.new(title: "New Chapter", position: 1)
    assert_not chapter.valid?
    assert_includes chapter.errors[:book], "must exist"
  end

  test "title is optional" do
    chapter = Chapter.new(book: books(:great_gatsby), position: 3)
    assert chapter.valid?
  end

  # Associations
  test "should belong to book" do
    chapter = chapters(:gatsby_chapter_one)
    assert_equal books(:great_gatsby), chapter.book
  end

  test "should have many passages" do
    chapter = chapters(:gatsby_chapter_one)
    assert_respond_to chapter, :passages
    assert chapter.passages.count >= 1
  end

  test "passages should be ordered by position" do
    chapter = chapters(:gatsby_chapter_one)
    positions = chapter.passages.pluck(:position)
    assert_equal positions.sort, positions
  end

  test "should destroy associated passages when destroyed" do
    chapter = chapters(:gatsby_chapter_one)
    passage_count = chapter.passages.count
    assert passage_count > 0

    assert_difference "Passage.count", -passage_count do
      chapter.destroy
    end
  end
end
