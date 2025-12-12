require "test_helper"

class TypingSessionTest < ActiveSupport::TestCase
  # Validations
  test "should be valid with valid attributes" do
    session = TypingSession.new(
      passage: passages(:gatsby_passage_one),
      wpm: 60,
      accuracy: 95.5,
      duration_seconds: 30
    )
    assert session.valid?
  end

  test "should require passage" do
    session = TypingSession.new(wpm: 60, accuracy: 95.5, duration_seconds: 30)
    assert_not session.valid?
    assert_includes session.errors[:passage], "must exist"
  end

  test "should require wpm" do
    session = TypingSession.new(
      passage: passages(:gatsby_passage_one),
      accuracy: 95.5,
      duration_seconds: 30
    )
    assert_not session.valid?
    assert_includes session.errors[:wpm], "can't be blank"
  end

  test "should require wpm to be non-negative" do
    session = TypingSession.new(
      passage: passages(:gatsby_passage_one),
      wpm: -1,
      accuracy: 95.5,
      duration_seconds: 30
    )
    assert_not session.valid?
    assert_includes session.errors[:wpm], "must be greater than or equal to 0"
  end

  test "should allow wpm of zero" do
    session = TypingSession.new(
      passage: passages(:gatsby_passage_one),
      wpm: 0,
      accuracy: 95.5,
      duration_seconds: 30
    )
    assert session.valid?
  end

  test "should require accuracy" do
    session = TypingSession.new(
      passage: passages(:gatsby_passage_one),
      wpm: 60,
      duration_seconds: 30
    )
    assert_not session.valid?
    assert_includes session.errors[:accuracy], "can't be blank"
  end

  test "should require accuracy to be non-negative" do
    session = TypingSession.new(
      passage: passages(:gatsby_passage_one),
      wpm: 60,
      accuracy: -1,
      duration_seconds: 30
    )
    assert_not session.valid?
    assert_includes session.errors[:accuracy], "must be greater than or equal to 0"
  end

  test "should require accuracy to be at most 100" do
    session = TypingSession.new(
      passage: passages(:gatsby_passage_one),
      wpm: 60,
      accuracy: 101,
      duration_seconds: 30
    )
    assert_not session.valid?
    assert_includes session.errors[:accuracy], "must be less than or equal to 100"
  end

  test "should require duration_seconds" do
    session = TypingSession.new(
      passage: passages(:gatsby_passage_one),
      wpm: 60,
      accuracy: 95.5
    )
    assert_not session.valid?
    assert_includes session.errors[:duration_seconds], "can't be blank"
  end

  test "should require duration_seconds to be positive" do
    session = TypingSession.new(
      passage: passages(:gatsby_passage_one),
      wpm: 60,
      accuracy: 95.5,
      duration_seconds: 0
    )
    assert_not session.valid?
    assert_includes session.errors[:duration_seconds], "must be greater than 0"
  end

  # Associations
  test "should belong to passage" do
    session = typing_sessions(:session_one)
    assert_equal passages(:gatsby_passage_one), session.passage
  end

  test "should have access to chapter through passage" do
    session = typing_sessions(:session_one)
    assert_equal chapters(:gatsby_chapter_one), session.passage.chapter
  end

  test "should have access to book through passage" do
    session = typing_sessions(:session_one)
    assert_equal books(:great_gatsby), session.passage.book
  end

  # Callbacks
  test "should set completed_at before create" do
    session = TypingSession.new(
      passage: passages(:gatsby_passage_one),
      wpm: 60,
      accuracy: 95.5,
      duration_seconds: 30
    )
    assert_nil session.completed_at

    session.save!

    assert_not_nil session.completed_at
  end

  test "should not override completed_at if already set" do
    custom_time = 1.hour.ago
    session = TypingSession.new(
      passage: passages(:gatsby_passage_one),
      wpm: 60,
      accuracy: 95.5,
      duration_seconds: 30,
      completed_at: custom_time
    )

    session.save!

    assert_in_delta custom_time, session.completed_at, 1.second
  end

  # Scopes
  test "recent scope orders by completed_at descending" do
    sessions = TypingSession.recent
    completed_times = sessions.pluck(:completed_at)
    assert_equal completed_times.sort.reverse, completed_times
  end
end
