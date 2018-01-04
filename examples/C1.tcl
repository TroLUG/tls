#!/usr/bin/tclsh

# client: socket without TLS


set s [socket localhost 10001]
fconfigure $s -buffering line -blocking 0

puts $s "Test1: ohne TLS  (1)"
while {1} {
  gets $s line
  if { [string length $line] == 0} {continue}
  
  puts  "Received: <$line>"
  break
}
  

puts $s "Test1: ohne TLS  (2)"
while {1} {
  gets $s line
  if { [string length $line] == 0} {continue}
  
  puts  "Received: <$line>"
  break
}

