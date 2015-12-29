# Remove Emojis
# This is a workaround until we handle this on database level
# https://github.com/taskrabbit/demoji

ActiveRecord::Base.send :include, Demoji
