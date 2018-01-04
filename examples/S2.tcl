#!/usr/bin/tclsh
# server: socket with TLS

package require tls

set dir     [file join [file dirname [info script]] certs]
set cafile  [file join $dir ca.pem]
set cert    [file join $dir server.pem]
set key     [file join $dir server.key]



proc Accept {s addr port} {
    fconfigure $s -buffering line
    fileevent $s readable [list handshake $s]
}

proc handshake {s} {
  if {[eof $s]} {
    puts "Closing ..."; close $s; exit
  } 
  if {[catch {tls::handshake $s} result]} {
    puts "handshake error: result: <$result>"; exit
  } 
  if {$result == 1} {
    puts "handshake done"
    fileevent $s readable [list Answer $s]      ;# wait for more data and from now on call other handler
  }
  after 1000             ;# necessary !!!
}



proc Answer {s} {
  if {[eof $s] || [catch {gets $s line}] } {
     puts "Closing socket ($s)"
     close $s
     return
  } 
  
  if {[string length $line] == 0} {puts "Nichts da"; return}
  #puts "Received: <$line>"
  puts -nonewline $s "echo: $line"
  flush $s
}

# main
tls::init -cafile $cafile -certfile $cert -keyfile $key
set s [tls::socket -server Accept  10002]
vwait forever

