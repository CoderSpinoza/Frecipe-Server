class DeviseCreateUserSessions < ActiveRecord::Migration
  def change
    create_table(:user_sessions) do |t|
      ## Database authenticatable

      t.references :user
      t.string :device
      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, :default => 0 # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## Token authenticatable
      t.string :authentication_token


      t.timestamps
    end
    # add_index :user_sessions, :confirmation_token,   :unique => true
    # add_index :user_sessions, :unlock_token,         :unique => true
    add_index :user_sessions, :authentication_token, :unique => true
  end
end
