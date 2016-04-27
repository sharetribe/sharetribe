class FixMissingPasswordData < ActiveRecord::Migration
  def up
    exec_update(
      "UPDATE people
       SET
         people.legacy_encrypted_password = people.encrypted_password
       WHERE
         encrypted_password NOT LIKE '$2a$10%' AND
         legacy_encrypted_password IS NULL",
      "Update missing legacy passwords",
      [])
  end

  def down
    # no-op
  end
end
