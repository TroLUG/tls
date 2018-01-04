#!/usr/bin/tclsh
# server: socket without TLS


proc Accept {s addr port} {
    fconfigure $s -buffering line
    fileevent $s readable [list Answer $s]
}


proc Answer {s} {
  if {[eof $s] || [catch {gets $s line}] } {
     puts "Closing socket ($s)"
     close $s
     return
  } 
  
  if {[string length $line] == 0} {puts "Nichts da"; return}
  #puts "Received: <$line>"
  puts $s "echo: $line"
  flush $s
}


# main

set s [socket -server Accept 10001]
vwait forever


