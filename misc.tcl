
proc mkproc {name arglist body args} {
	set body [string map $args $body]
	proc $name $arglist $body
}
