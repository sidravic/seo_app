# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_seo_engine_session',
 :secret      => 'c274a7a76b1d0b0ea0e53ea115e1fa6a719501c664deba246bba3148364cf04d4fb37d0fd264810b462e50215377e2333377bd38f6f22fc700a72064b7131ddf'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
