proc interpret-where-clause {args} {
	
	lappend clause_list
	
	foreach statement [lindex $args 0] {

		if {[llength $statement] == 3} then {
			set field [lindex $statement 0]
			set operation [lindex $statement 1]
			set value [lindex $statement 2]

		} else {
			set field [lindex $statement 0]
			set value [string range $statement [string length $field]+1 end]
			set operation "="

		}

		lappend clause_list "$field $operation $value"
	}		

	return $clause_list
}

proc select {model info} {
	array set info_arr $info

	eval "set table \${${model}::table_name}"
	set fields "*"
	set where_clause "1 = 1"
	set orderby ""
	set limit ""

	if {[info exists info_arr(where)]} then {
		set where_clause_unsubst [where {*}$info_arr(where)]
		set where_clause [uplevel 1 subst -nocommands [list $where_clause_unsubst]]
	}

	if {[info exists info_arr(order)]} then {
		set order [uplevel 1 subst -nocommands [list $info_arr(order)]]
		set orderby "ORDER BY $order"
	}

	if {[info exists info_arr(limit)]} then {

		lassign $info_arr(limit) from_index length
		if {$length == ""} then {
			set from_index  [uplevel 1 subst -nocommands $from_index]
			set limit "LIMIT $from_index"
		} else {
			set from_index  [uplevel 1 subst -nocommands $from_index]
			set length  [uplevel 1 subst -nocommands $length]
			set limit "LIMIT $from_index, $length"
		}
	}

	return "SELECT $fields FROM $table WHERE $where_clause $orderby $limit"
}

proc where {args} {
	set clause ""
	
	set clause_list [interpret-where-clause $args]

	for {set idx 0} {$idx < [llength $clause_list]} {incr idx} {
		set current [lindex $clause_list $idx]
		set clause "$clause$current"

		if {$idx < [expr {[llength $clause_list]-1}]} then {
			set clause "$clause AND "
		}
	}
	return $clause
}

#
#	Create two procedures in the namespace
#
#	1. $name -> returns the query
#   2. find-$name -> returns the mysql query's results.
#
proc named-query {name sig body} {
	set current_namespace [uplevel 1 namespace current]
	mkproc "${current_namespace}::$name" $sig {
		%body%
	} %body% $body

	mkproc "${current_namespace}::find-$name" $sig {
		set query [%ns%::%name%]
		return [db'get-results-for %ns% $query]

	} %ns% $current_namespace %name% $name
}