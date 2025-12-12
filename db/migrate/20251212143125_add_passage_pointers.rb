class AddPassagePointers < ActiveRecord::Migration[8.0]
  def change
    add_reference :passages, :previous_passage, foreign_key: { to_table: :passages }
    add_reference :passages, :next_passage, foreign_key: { to_table: :passages }
  end
end
