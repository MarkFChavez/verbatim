class BooksController < ApplicationController
  before_action :set_book, only: [ :show, :destroy, :continue ]

  def index
    @books = Book.all.order(created_at: :desc)
  end

  def show
    @pagy, @chapters = pagy(@book.chapters.includes(:passages))
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

    @book = Book.new(
      title: result.title,
      author: result.author,
      uploaded_at: Time.current
    )

    if @book.save
      # Attach cover image if present
      if result.cover
        @book.cover_image.attach(
          io: StringIO.new(result.cover[:data]),
          filename: result.cover[:filename],
          content_type: result.cover[:media_type]
        )
      end

      # Attach original epub for reference
      @book.epub_file.attach(epub_file)

      # Create chapters and passages
      create_chapters_and_passages(result.chapters)

      redirect_to @book, notice: "Book uploaded successfully!"
    else
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

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def create_chapters_and_passages(chapters_data)
    chapters_data.each_with_index do |chapter_data, chapter_index|
      chapter = @book.chapters.create!(
        title: chapter_data.title,
        position: chapter_index + 1
      )

      passages = PassageSplitterService.new(chapter_data.content).split

      passages.each_with_index do |content, passage_index|
        chapter.passages.create!(
          content: content,
          position: passage_index + 1
        )
      end
    end
  end
end
