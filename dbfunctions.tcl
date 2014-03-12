
proc table {name {primary_key "id"}} {

	uplevel 1 {
		variable columns
		variable mappings
		variable table_name
		variable primary
	}

	set ns_name [uplevel 1 namespace current]

	set ${ns_name}::table_name $name
	set ${ns_name}::primary $primary_key

	set generatedqueries {
		all {"select * from $name"}
		find {"select * from $name where $primary_key = :id"}
	}

	foreach {q_name query} $generatedqueries {
		set fullq [expr $query]
		db'prepare-query $ns_name $q_name $name $fullq
	}						

}

#
#   Add a belongs to mapping
#
proc belongs-to {key local_key mapping} {

	set ns [uplevel 1 {namespace current}]
	lassign $mapping target_ns foreign_key 

	set mapvar ${ns}::mapping

	lappend $mapvar $key [list \
		type "belongs-to" \
		target $target_ns \
		local_key $local_key \
		query "select * from :table where :foreign_key = :id" \
		multiple false
	]

}

proc has {key mapping} {
	set ns [uplevel 1 {namespace current}]
	lassign $mapping target_ns foreign_key

	set mapvar ${ns}::mapping

	lappend $mapvar $key [list \
		type "has" \
		target $target_ns \
		query "select * from :table where $foreign_key = :id" \
		multiple true
	]
}


proc db'merge-arguments-with-query {query args} {

	foreach arg $args {
		lassign $arg from to
		set query [string map [list $from $to] $query]
	}

	return $query
}

proc db'get-results-for {db_source namesp table query} {

	set cols [mysql::col $db_source $table name]
	set resultset [mysql::sel $db_source $query -list]

	lappend arr_result

	foreach row $resultset {
		set arr_row [list _from_table $table _namespace $namesp _from_query $query]

		for {set idx 0} {$idx < [llength $row]} {incr idx} {
			lappend arr_row [lindex $cols $idx]
			lappend arr_row [lindex $row $idx]
		}

		if {[llength $resultset] == 1} then {
			return $arr_row
		} else {
			lappend arr_result $arr_row
		}
	}

	puts $arr_result

	return $arr_result

}

proc db'prepare-query {ns name table query} {
	# puts "registering query $name {$query}" 

	set fullname "${ns}::$name"

	mkproc $fullname {args} {
		global m
		set merged_query [db'merge-arguments-with-query "%query%" {*}$args]
		return [db'get-results-for $m %ns% "%table%" $merged_query]
	} %name% $name %query% $query %table% $table %ns% $ns

}