module Onboardable
  extend ActiveSupport::Concern

  included do
    after_create :create_sample_book
  end

  private

  def create_sample_book
    book = books.create!(
      title: "Typing Practice",
      author: "TypeLit",
      uploaded_at: Time.current
    )

    # Chapter 1: Basic sentences
    chapter1 = book.chapters.create!(title: "Getting Started", position: 1)

    chapter1_passages = [
      "The quick brown fox jumps over the lazy dog. This sentence contains every letter of the alphabet, making it perfect for typing practice.",
      "Practice makes perfect. The more you type, the faster and more accurate you will become. Keep your fingers on the home row and maintain a steady rhythm.",
      "Learning to type without looking at the keyboard is an essential skill. Focus on the screen and trust your muscle memory to find the right keys.",
      "Good posture is important when typing. Sit up straight, keep your wrists level, and position your keyboard at a comfortable height.",
      "Take breaks when you need them. Typing for long periods can strain your hands and eyes. Rest, stretch, and return refreshed."
    ]

    chapter1_passages.each_with_index do |content, i|
      chapter1.passages.create!(content: content, position: i + 1)
    end

    # Chapter 2: Longer passages
    chapter2 = book.chapters.create!(title: "Building Speed", position: 2)

    chapter2_passages = [
      "Speed comes with time and consistent practice. Do not rush or sacrifice accuracy for speed. A steady, rhythmic typing pace will naturally increase your words per minute over time.",
      "Common words appear frequently in everyday writing. Words like the, and, that, have, for, are, with, you, this, and from make up a large portion of most texts. Mastering these words will boost your overall speed.",
      "Numbers and symbols require extra attention. The top row of the keyboard contains digits from one to zero. Special characters like the at sign, hash, dollar, and percent are used in emails, social media, and programming.",
      "Typing is a skill that transfers across many areas of life. From writing emails and documents to chatting with friends and coding software, fast and accurate typing saves time and reduces frustration."
    ]

    chapter2_passages.each_with_index do |content, i|
      chapter2.passages.create!(content: content, position: i + 1)
    end
  end
end
