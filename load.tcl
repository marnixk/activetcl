package provide activetcl 1.0

package require mysqltcl

set pkg_dir [file dirname [info script]]

source "$pkg_dir/misc.tcl"
source "$pkg_dir/dbfunctions.tcl"
source "$pkg_dir/dbpersist.tcl"
source "$pkg_dir/dbqueries.tcl"
source "$pkg_dir/dbassocs.tcl"

