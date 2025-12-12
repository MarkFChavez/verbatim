require "test_helper"

class UserTest < ActiveSupport::TestCase
  # Validations
  test "should be valid with valid attributes" do
    user = User.new(username: "testuser", password: "password123")
    assert user.valid?
  end

  test "should require username" do
    user = User.new(password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:username], "can't be blank"
  end

  test "should require unique username" do
    User.create!(username: "uniqueuser", password: "password123")
    user = User.new(username: "uniqueuser", password: "password456")
    assert_not user.valid?
    assert_includes user.errors[:username], "has already been taken"
  end

  test "should require password" do
    user = User.new(username: "testuser")
    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end

  # Authentication
  test "should authenticate with correct password" do
    user = users(:alice)
    assert user.authenticate("password123")
  end

  test "should not authenticate with incorrect password" do
    user = users(:alice)
    assert_not user.authenticate("wrongpassword")
  end

  # Associations
  test "should have many books" do
    user = users(:alice)
    assert_respond_to user, :books
    assert_kind_of ActiveRecord::Associations::CollectionProxy, user.books
  end

  test "should have many staged_books" do
    user = users(:alice)
    assert_respond_to user, :staged_books
    assert_kind_of ActiveRecord::Associations::CollectionProxy, user.staged_books
  end

  test "should destroy associated books when destroyed" do
    user = users(:alice)
    book_count = user.books.count
    assert book_count > 0

    assert_difference "Book.count", -book_count do
      user.destroy
    end
  end

  test "should destroy associated staged_books when destroyed" do
    user = users(:alice)
    staged_count = user.staged_books.count
    assert staged_count > 0

    assert_difference "StagedBook.count", -staged_count do
      user.destroy
    end
  end
end
