#!/usr/bin/tclsh

package require mysqltcl

source "misc.tcl"
source "dbfunctions.tcl"
source "dbassocs.tcl"

set m [mysql::connect -user root -password r2d2c3po -db tclmysql]
mysql::use $m tclmysql


namespace eval Company {

	table companies

}

namespace eval Category {

	table categories
	has games {Game category_id}

}

namespace eval Rating {
	table ratings
	belongs-to game game_id {Game id}
}

namespace eval Game {

	table games
	belongs-to category category_id {Category id}
	has ratings {Rating game_id}

}


# array set category [Category::find {:id 7}]
# set complete_category [db'unfold {games} [array get category] -single]

set category [db'unfold {games} [Category::find {:id 7}] -single]
puts $category

set game [Game::find {:id 34}]
set complete_game [db'unfold {category ratings} $game -single]

array set cga $complete_game
unset category
array set category $cga(category)
set ratings $cga(ratings)

foreach rating $ratings {
	array set r $rating
	parray r
	puts ""
}

parray category

# parray game
# puts "complete game: $complete_game"
# puts "complete category: $complete_category"


mysql::close $m
