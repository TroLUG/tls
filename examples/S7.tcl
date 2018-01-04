# server: https with multi-threading

package require tls
package require Thread
package require cmdline



# -----------------------------------------------------------------------------------
proc usage { } {
    puts { \nusage: tclsh client.tcl <options>

    -wt  <waittime>     time in msec to delay returning answer, Def. 1000
    }
}  


# ---------------------------------------------------------------------------
proc accept { s addr port } {
  puts "accept: Starting ...     (socket: $s, Addr: $addr, Port: $port)"
  global wt
  
  fconfigure $s -blocking 0
  
  set id [thread::create -joinable {
  
    package require tls
    global wtt                     ;# global var of this tread
    
    # ---------------
    proc calc {in} {
      set delim "\r\n"
      set ind [string first $delim$delim $in]
      if {$ind < 0} { set delim "\n"; set ind [string first $delim$delim $in] }
      if {$ind < 0} { return -1 }
      set Ldelim [string length $delim]
      
      set op [string range $in [expr $ind + 2 * $Ldelim] end ]
      if { [string index $op end] == "\n" } { set op [string range $op 0 end-1] }
      if { [string index $op end] == "\r" } { set op [string range $op 0 end-1] }
      
      #set res [expr $op]
      if {[catch {expr $op} res]} { set res error }
      puts "calc: $op=$res"
      return $res
    }
    
    # ---------------
    proc respond {s} {
      global wtt

      if {[catch {read $s} data]} { puts "respond: Error --> Closing ..."; close $s; exit }
      if {[eof $s]} { 
        #puts "respond: EOF"
        after 100
        return 
      }
  
      #puts "respond: Received: <$data>"
      set res [calc $data]
      
      set    header "HTTP/1.1 200 OK\r\n"                        ;# mandatory
      append header "Content-Length: [string length $res]\r\n"   ;# mandatory
      #append header "Connection:keep-alive\r\n"                 ;# ok
      append header "Connection: close\r\n"

      set response "${header}\r\n${res}"
      
      if {$wtt != 0} { puts "respond: waiting $wtt msec before returning answer..."; after $wtt }
      #puts "\nrespond: Returning: <$response> ..."
      if {$wtt != 0} { puts "respond: returning response: $res..." }
      puts -nonewline $s $response
      flush $s
    }

    # --------------
    proc handshake {s} {  
      if {[eof $s]} {
        puts "handshake: Closing ..."; close $s; exit
      } 
      if {[catch {tls::handshake $s} result]} {
        puts "handshake: Error, result: <$result>"; exit
      } 
      if {$result == 1} {
        #puts "handshake: done"
        fileevent $s readable [list respond $s]      ;# wait for more data and from now on call other handler
      }
      after 1000             ;# necessary !!!
    }
    
    # --------------
    proc HandleConnection {s wt} {
      #puts "HandleConnection: Starting ...   (s: $s, wt: $wt)"
      
      # save wt to global variable of this thread
      global wtt
      set wtt $wt
      
      fileevent $s readable [list handshake $s]
    }

    thread::wait
  }]  ;# thread::create
  
  #puts "Thread created: ID=$id"
  after 0 [list HandOver $id $s $wt]
  return
}




# -----------------------------------------------------------------------------------
# main

global wt                                  ;# time in msec to delay returning answer

set dir     [file join [file dirname [info script]] certs]
set cafile  [file join $dir ca.pem]
set cert    [file join $dir server.pem]
set key     [file join $dir server.key]
  
set options {
    {h                            "help" }
    {wt.arg            0          "time in msec to delay returning answer"}
}

array set arg [cmdline::getoptions argv $options]
if { $arg(h) } { usage;  exit}
set wt $arg(wt)


tls::init -cafile $cafile -certfile $cert -keyfile $key
set chan [tls::socket -server accept -require 1  10005]


proc HandOver {id s wt} {
    thread::transfer $id $s
    thread::send -async $id [list HandleConnection $s $wt]
    return
}
 
vwait forever


