
#
#	save a model by inserting it if it has no identifier, or 
# 	update an existing record if it does.
#
#	Example: db'save Person {name "my name"} for a new record
#			 db'save Person {id 1 name "my name"} to update record with id = 1
#
#   If it is a new record, the newly inserted record's ID is returned as a value.
#
proc db'save {model_name model} {
	global db_conn

	set tablename [subst "\$${model_name}::table_name"]
	set primary_key [subst "\$${model_name}::primary"]

	array set model_arr $model 

	if {[info exists model_arr($primary_key)]} then {

		# key exists in array? update.
		set clause [db'persist-clause $model $primary_key]
		set query "UPDATE $tablename SET $clause WHERE $primary_key = $model_arr($primary_key)" 
		mysql::exec $db_conn $query

	} else {

		# key didn't exist, make insert statement
		set clause [db'persist-clause $model]
		set query "INSERT INTO $tablename SET $clause"
		mysql::exec $db_conn $query
		return [mysql::insertid $db_conn]
	}
}

#
#	Delete a record of type `model_name` with values `model` from
#	the database
#
proc db'delete {model_name model} {
	global db_conn

	set tablename [subst "\$${model_name}::table_name"]
	set primary_key [subst "\$${model_name}::primary"]
	array set model_arr $model

	if {[info exists model_arr($primary_key)]} then {
		set key_value [mysql::escape $model_arr($primary_key)]
		set query "DELETE FROM $tablename WHERE $primary_key = $key_value"
		mysql::exec $db_conn $query
	} else {
		puts "cannot delete record without identifying key."
	}


}


proc db'persist-clause {model {skip ""}} {
	
	lappend c_arr

	# array set model_arr $model
	foreach {field val} $model {
		if {$skip == $field} then {
			continue
		}

		lappend c_arr "$field = \"[mysql::escape $val]\""
	}

	return [join $c_arr ", "]
}
