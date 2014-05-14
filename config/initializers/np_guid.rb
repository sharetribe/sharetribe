# Copyright (c) 2005-2007 Assembla, LLC
#
# This plugin for ActiveRecord makes the "ID" field into a URL-safe GUID
# It is a mashup by Andy Singleton <andy@assembla.com> that includes
# * the UUID class from Bob Aman.
# * the plugin skeleton from Demetrius Nunes
# * the 22 character URL-safe format from Andy Singleton
# You can get standard 36 char UUID formats instead
# TODO: Auto-detect a character ID field and use a GUID in this case (DRY principle)
#
# This library is free software; you can redistribute it and/or modify it
# under the terms of the MIT license.
#
# TO USE
# Install as a plugin in the rails directory vendor/plugin/guid
# define ID as char(22)
# call "usesguid" in ActiveRecord class declaration, like
#   class Mymodel < ActiveRecord::Base
#	  usesguid
#
# if your ID field is not called "ID", call "usesguid :column =>'IdColumnName' "

# if you create your tables with migrations, you need to bypass the rails default primary key index. Do this:
#   create_table :mytable, :id => false do |t|
#     t.column :id, :string, :limit => 22
#     ... more fields
#   end
#   execute "ALTER TABLE mytable ADD PRIMARY KEY (id)"

require File.expand_path('../../../lib/np_guid/usesnpguid', __FILE__)
require File.expand_path('../../../lib/np_guid/uuid22', __FILE__)
