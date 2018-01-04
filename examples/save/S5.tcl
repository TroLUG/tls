# server: https (http and TLS)

package require tls

set dir     [file join [file dirname [info script]] certs]
set cafile  [file join $dir ca.pem]
set cert    [file join $dir server.pem]
set key     [file join $dir server.key]




proc respond {s} {

  if {[catch {read $s} data]} { puts "respond: Error --> Closing ..."; close $s; exit }
  if {[eof $s]} { puts "respond: EOF"; after 2000; return }
  
  puts "respond: Received: <$data>"
  
  set data "1234567890"

  set    header "HTTP/1.1 200 OK\r\n"                        ;# mandatory
  append header "Content-Length: [string length $data]\r\n"  ;# mandatory
  #append header "Connection:keep-alive\r\n"                 ;# ok
  append header "Connection: close\r\n"

  set response "${header}\r\n${data}"
  puts "\nrespond: Returning: <$response> ..."
  puts -nonewline $s $response
  flush $s
}


proc handshake {s} {
  if {[eof $s]} {
    puts "handshake: Closing ..."; close $s; exit
  } 
  if {[catch {tls::handshake $s} result]} {
    puts "handshake: Error, result: <$result>"; exit
  } 
  if {$result == 1} {
    puts "handshake: done"
    fileevent $s readable [list respond $s]      ;# wait for more data and from now on call other handler
  }
  after 1000             ;# necessary !!!
}


proc accept { s addr port } {
    puts "accept: Starting ...     (socket: $s, Addr: $addr, Port: $port)"
    fconfigure $s -blocking 0
    fileevent $s readable [list handshake $s]
}

# ---------------------------------------------------------------------------
# main
tls::init -cafile $cafile -certfile $cert -keyfile $key
set chan [tls::socket -server accept 10005]
vwait forever


