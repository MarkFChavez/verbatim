require "test_helper"

class PassageTest < ActiveSupport::TestCase
  # Validations
  test "should be valid with valid attributes" do
    passage = Passage.new(
      chapter: chapters(:gatsby_chapter_one),
      content: "Some text content.",
      position: 10
    )
    assert passage.valid?
  end

  test "should require content" do
    passage = Passage.new(chapter: chapters(:gatsby_chapter_one), position: 10)
    assert_not passage.valid?
    assert_includes passage.errors[:content], "can't be blank"
  end

  test "should require position" do
    passage = Passage.new(chapter: chapters(:gatsby_chapter_one), content: "Some text.")
    assert_not passage.valid?
    assert_includes passage.errors[:position], "can't be blank"
  end

  test "should require chapter" do
    passage = Passage.new(content: "Some text.", position: 1)
    assert_not passage.valid?
    assert_includes passage.errors[:chapter], "must exist"
  end

  # Associations
  test "should belong to chapter" do
    passage = passages(:gatsby_passage_one)
    assert_equal chapters(:gatsby_chapter_one), passage.chapter
  end

  test "should have book through chapter" do
    passage = passages(:gatsby_passage_one)
    assert_equal books(:great_gatsby), passage.book
  end

  test "should have many typing_sessions" do
    passage = passages(:gatsby_passage_one)
    assert_respond_to passage, :typing_sessions
    assert passage.typing_sessions.count >= 1
  end

  test "should destroy associated typing_sessions when destroyed" do
    passage = passages(:gatsby_passage_one)
    session_count = passage.typing_sessions.count
    assert session_count > 0

    assert_difference "TypingSession.count", -session_count do
      passage.destroy
    end
  end

  # Callbacks
  test "should calculate word_count before save" do
    passage = Passage.new(
      chapter: chapters(:gatsby_chapter_one),
      content: "One two three four five.",
      position: 10
    )
    passage.save!

    assert_equal 5, passage.word_count
  end

  test "should recalculate word_count on update" do
    passage = passages(:gatsby_passage_one)
    passage.update!(content: "Just three words.")

    assert_equal 3, passage.word_count
  end

  # Methods
  test "completed? returns true when typing sessions exist" do
    passage = passages(:gatsby_passage_one)
    assert passage.completed?
  end

  test "completed? returns false when no typing sessions" do
    passage = passages(:moby_passage_one)
    assert_not passage.completed?
  end

  test "best_session returns session with highest wpm" do
    passage = passages(:gatsby_passage_one)
    best = passage.best_session

    assert_not_nil best
    assert_equal typing_sessions(:session_two), best # wpm: 72
  end

  test "best_session returns nil when no sessions" do
    passage = passages(:moby_passage_one)
    assert_nil passage.best_session
  end

  test "next_passage returns next passage in same chapter" do
    passage = passages(:gatsby_passage_one)
    assert_equal passages(:gatsby_passage_two), passage.next_passage
  end

  test "next_passage returns first passage of next chapter when at end of chapter" do
    passage = passages(:gatsby_passage_two)
    # Next should be gatsby_passage_three which is in chapter 2
    assert_equal passages(:gatsby_passage_three), passage.next_passage
  end

  test "next_passage returns nil when at end of book" do
    passage = passages(:gatsby_passage_three)
    assert_nil passage.next_passage
  end

  test "previous_passage returns previous passage in same chapter" do
    passage = passages(:gatsby_passage_two)
    assert_equal passages(:gatsby_passage_one), passage.previous_passage
  end

  test "previous_passage returns last passage of previous chapter when at start of chapter" do
    passage = passages(:gatsby_passage_three)
    # Previous should be gatsby_passage_two which is the last in chapter 1
    assert_equal passages(:gatsby_passage_two), passage.previous_passage
  end

  test "previous_passage returns nil when at start of book" do
    passage = passages(:gatsby_passage_one)
    assert_nil passage.previous_passage
  end
end
