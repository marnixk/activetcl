#!/usr/bin/tclsh

package require mysqltcl

source "misc.tcl"
source "dbfunctions.tcl"
source "dbassocs.tcl"
source "dbqueries.tcl"



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

	proc latest-games {{top 5}} {
		return [db'get-results-for Game "SELECT * FROM games ORDER BY updated_at DESC LIMIT $top"]
	}

	proc hot-games {{top 5}} {
		return [db'get-results-for Game "SELECT * FROM games WHERE is_hot_game = 1 ORDER BY updated_at DESC LIMIT $top"]
	}


}



db'connect -user root -password r2d2c3po -db tclmysql

set games [Game::latest-games]
set all_games [Game::all]
set specific_game [Game::find {:id 10}]

puts [where { {id > 10} {category_id 10} {name "marnix kok"} }]

db'close