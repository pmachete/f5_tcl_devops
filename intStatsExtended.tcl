# This is an extended version of intStats from devcentral F5

modify script intStatsExtended {
proc script::run {} {
       tmsh::clear_screen

       set interfaceList {}
       set intfraw [split [tmsh::list net interface enabled] "\n"]
       foreach aInt $intfraw  {
           set aInt2 [split $aInt " "]
           set aInt3 [lindex $aInt2 2]
           if {([lindex $aInt2 0] == "net") && ([lindex $aInt2 1] == "interface")} {
              lappend interfaceList $aInt3
           }
       }

       set l1 []
       set l2 []
       set interval 5
       set delay [expr $interval * 1000]
       set list1values {}
       foreach aInt $interfaceList  {
            set l1 []
            lappend l1 [lindex [lindex [split [tmsh::show net interface $aInt raw field-fmt] "\n"] 1] 1]
            lappend l1 [lindex [lindex [split [tmsh::show net interface $aInt raw field-fmt] "\n"] 2] 1]
            lappend list1values $l1
       }

       puts "Wait $interval seconds. capturing data ..."
       while { true } {

              after $delay
              set list2values {}
              set count 0
              tmsh::clear_screen
              puts "Interface\t\tInbound (bps)\t\tOutbound (bps)"

              foreach aInt $interfaceList  {
                  set l2 {}
                  lappend l2 [lindex [lindex [split [tmsh::show net interface $aInt raw field-fmt] "\n"] 1] 1]
                  lappend l2 [lindex [lindex [split [tmsh::show net interface $aInt raw field-fmt] "\n"] 2] 1]
                  lappend list2values $l2
                  set l1 [lindex $list1values $count]
                  set statsIn  [expr ([lindex $l2 0] - [lindex $l1 0]) / $interval]
                  set statsOut [expr ([lindex $l2 1] - [lindex $l1 1]) / $interval]

                  puts "$aInt\t\t\t$statsIn\t\t\t$statsOut"
                  incr count
              }
              set list1values $list2values

              unset l2

       }
}
}
@@
