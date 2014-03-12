
#
#  Unfold the associations for these rows
#  
proc db'unfold {assocs rows {type -multiple}} {

	if {$type == "-single"} then {
		return [db'unfold-row $assocs $rows]
	} else {
		lappend result 
		foreach row $rows {
			lappend result [db'unfold-row $assocs $row]
		}
		return $result
	}

}

#
#  unfold a single row
# 
proc db'unfold-row {assocs row} {

	array set row_arr $row

	# new result structure
	# { row => .. original row .., "assocname1" => ... assoc array .. }
	set result [list row $row]
	
	# do some double substitution magic
	eval "set map_info \${${row_arr(_namespace)}::mapping}"
	array set map_array $map_info

	# iterate over wanted association mappings
	foreach assoc $assocs {

		# make sure it exists
		if {! [info exists map_array($assoc)]} then {
			puts "Could find association `$assoc`. aborting"
			return
		}

		array set assoc_arr $map_array($assoc)

		eval "set target_table \$${assoc_arr(target)}::table_name"

		# handle properly
		set fetch_args [list]

		switch $assoc_arr(type) {
			"belongs-to" {
				lappend result $assoc [db'fetch-belongs-to $assoc_arr(query) $assoc_arr(target) $assoc_arr(local_key) $target_table $row]
			}
			"has" {
				lappend result $assoc [db'fetch-has $assoc_arr(query) $assoc_arr(target) $target_table $row_arr(id)]
			}
		}
	}

	return $result
}

proc db'fetch-has {query ns table id} {
	set merged_query [db'merge-arguments-with-query $query [list :table $table] [list :id $id]]
	return [db'get-results-for $ns $merged_query]
}

proc db'fetch-belongs-to {query ns local_key table row} {
	array set row_arr $row
	eval "set fkey \${${ns}::primary}"
	set merged_query [db'merge-arguments-with-query $query [list :table $table] [list :id $row_arr($local_key)] [list :foreign_key $fkey]]

	return [db'get-results-for $ns $merged_query]
}
