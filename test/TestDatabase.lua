--[[

Copyright 2015 MongoDB, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

--]]

require('luaHelperFunctions')
local lu = require("luaunit")

local BaseTest = require("BaseTest")


TestDatabase = {}
setmetatable(TestDatabase, {__index = BaseTest})

	function TestDatabase:test_database_drop()
		-- ensure database exists
		self.collection:insert_one({})
		
		local database_names = self.client:getDatabaseNames()
		lu.assertTrue(inArray(self.database_name, database_names))
		
		self.database:drop_database()
		database_names = self.client:getDatabaseNames()
		lu.assertFalse(inArray(self.database_name, database_names))
	end

	function TestDatabase:test_database_index_into_collection()
		lu.assertEquals(self.collection_name, "foo", "this test assumes collection name is foo")

		local other_collection = self.database.foo
		local count = other_collection:count()
		lu.assertEquals(count, 0)

		local document_to_insert = {["test"] = "test_database_index_into_collection"}
		
		-- insert with indexing syntax, find one with :getCollection(...) syntax
		self.collection:insert_one(document_to_insert)
		local document = other_collection:find_one()
		
		lu.assertTrue(table_eq(document_to_insert, document))
	end
	
	function TestDatabase:test_get_collection_names()
		self.collection:insert_one({})
		
		local collection_names = self.database:getCollectionNames()
		lu.assertTrue(inArray(self.collection_name, collection_names))
		
		self.collection:drop()
		
		collection_names = self.database:getCollectionNames()
		lu.assertFalse(inArray(self.collection_name, collection_names))
	end
	
	function TestDatabase:test_command()
		self.collection:insert_many({{x = 1}, {x = 1}, {x = 2}})
		
		-- Test default value defaulting to 1.
		local response = self.database:command("buildinfo")
		lu.assertTrue(response.ok)
		
		-- Test value given.
		response = self.database:command("collstats", self.collection_name)
		lu.assertTrue(response.ok)
		
		-- Test command options.
		response = self.database:command("distinct", self.collection_name, {key = "x"})
		local values = response.values
		
		lu.assertTrue(inArray(1, values))
		lu.assertTrue(inArray(2, values))
	end

lu.run()
