class AddLegacyEncryptedPassword < ActiveRecord::Migration
  # Note: This migration will lose data and make logging in impossible without password resets when migrated down.

  def change
    reversible do |dir|
      dir.up {
        add_column :people, :legacy_encrypted_password, :string, limit: 255, after: :encrypted_password, null: true, default: nil
        execute("UPDATE people SET legacy_encrypted_password = encrypted_password WHERE password_salt IS NOT NULL")
      }

      dir.down {
        execute("UPDATE people SET encrypted_password = legacy_encrypted_password WHERE legacy_encrypted_password IS NOT NULL")
        remove_column :people, :legacy_encrypted_password
      }
    end
  end
end
