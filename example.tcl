#!/usr/bin/tclsh

package require mysqltcl

source "misc.tcl"
source "dbfunctions.tcl"
source "dbassocs.tcl"
source "dbqueries.tcl"
source "dbpersist.tcl"



namespace eval Company {
	table "companies"
}

namespace eval Category {
	table "categories"
	has games {Game category_id}
}

namespace eval Rating {
	table "ratings"
	belongs-to game game_id {Game id}
}

namespace eval Game {

	table "games"
	belongs-to category category_id {Category id}
	belongs-to company company_id {Company id}
	has ratings {Rating game_id}

	named-query latest-games {{top 5}} {
		select Game {
			order "updated_at DESC"
			limit $top
		}
	}

	named-query hot-games {{top 5}} {
		set order "updated_at"
		select Game {
			where { {is_hot_game 1} }
			order "$order DESC"
			limit $top
		}
	}

}



db'connect -user root -password r2d2c3po -db tclmysql

set newid [db'save Company {
	name "new company" 
	url "http://google.com" 
	description "Amazing stuff happening in this company, so happy to be working here"
}]

puts "Added record with id: $newid"

db'delete Company [subst {id $newid}]

db'save Company {
	id 17
	name "Updated Unregistered Company" 
	url "http://google.com" 
	description "Amazing stuff happening in this company, so happy to be working here"
}



# set games [Game::latest-games]
# set all_games [Game::all]
# set specific_game [Game::find {:id 10}]

# puts $specific_game

# set top 20
# set length 5
# set category_id 10
# set name {"Marnix Kok"}

# puts [select Game {
# 	where { 
# 		{id > 10} 
# 		{category_id $category_id} 
# 		{name $name} 
# 	}
# 	order "updated_at DESC"
# 	limit {$top $length}
# }]

# set latest-games [Game::find-hot-games]
# puts ${latest-games}

db'close