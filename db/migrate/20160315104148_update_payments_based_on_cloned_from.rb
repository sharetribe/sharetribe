class UpdatePaymentsBasedOnClonedFrom < ActiveRecord::Migration
  def up
    ActiveRecord::Base.transaction do
      # Update payer id
      execute("
        UPDATE payments AS pa, people AS pe
        SET pa.payer_id = pe.id
        WHERE
          pa.payer_id = pe.cloned_from AND
          pa.community_id = pe.community_id
      ")

      # Update recipient id
      execute("
        UPDATE payments AS pa, people AS pe
        SET pa.recipient_id = pe.id
        WHERE
          pa.recipient_id = pe.cloned_from AND
          pa.community_id = pe.community_id
      ")
    end
  end

  def down
    ActiveRecord::Base.transaction do
      # Roll back payer id
      execute("
        UPDATE payments AS pa, people AS pe
        SET pa.payer_id = pe.cloned_from
        WHERE
          pa.payer_id = pe.id AND
          pe.cloned_from IS NOT NULL
      ")

      # Roll back recipient id
      execute("
        UPDATE payments AS pa, people AS pe
        SET pa.recipient_id = pe.cloned_from
        WHERE
          pa.recipient_id = pe.id AND
          pe.cloned_from IS NOT NULL
      ")
    end
  end
end
