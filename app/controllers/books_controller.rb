class BooksController < ApplicationController
  before_action :set_book, only: [ :show, :destroy, :continue, :search ]

  def index
    @books = current_user.books.order(created_at: :desc)
  end

  def show
    @current_passage = @book.current_passage
  end

  def new
    @book = Book.new
  end

  def create
    epub_file = params[:book][:epub_file]

    unless epub_file
      @book = Book.new
      @book.errors.add(:epub_file, "must be provided")
      render :new, status: :unprocessable_entity
      return
    end

    result = EpubParserService.new(epub_file.tempfile).parse

    chapters_data = result.chapters.map do |chapter|
      { "title" => chapter.title, "content" => chapter.content, "included" => true }
    end

    staged_book = current_user.staged_books.build(
      title: result.title,
      author: result.author,
      chapters_data: chapters_data
    )

    if staged_book.save
      if result.cover
        staged_book.cover_image.attach(
          io: StringIO.new(result.cover[:data]),
          filename: result.cover[:filename],
          content_type: result.cover[:media_type]
        )
      end

      staged_book.epub_file.attach(epub_file)

      redirect_to staged_book
    else
      @book = Book.new
      @book.errors.add(:base, "Error staging book")
      render :new, status: :unprocessable_entity
    end
  rescue StandardError => e
    @book = Book.new
    @book.errors.add(:base, "Error processing epub: #{e.message}")
    render :new, status: :unprocessable_entity
  end

  def destroy
    @book.destroy
    redirect_to books_path, notice: "Book deleted."
  end

  def continue
    passage = @book.current_passage

    if passage
      redirect_to passage_path(passage)
    else
      redirect_to @book, alert: "No passages found in this book."
    end
  end

  def search
    @query = params[:q].to_s.strip
    @results = @query.present? ? @book.passages.search(@query).includes(:chapter).limit(20) : []
    @current_passage = @book.current_passage
  end

  private

  def set_book
    @book = current_user.books.find(params[:id])
  end
end
