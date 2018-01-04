
# client: set with TLS

package require tls

set dir     [file join [file dirname [info script]] certs]
set cafile  [file join $dir ca.pem]
set cert    [file join $dir client.pem]
set key     [file join $dir client.key]


proc send {s} {

    puts  $s "Test2: mit TLS  (1)"
    flush $s
    
    puts  $s "Test2: mit TLS  (2)"
    flush $s

    fileevent $s writable {}    ;# needed to stop, otherwise this proc is called again and again
    
    #after 5000; exit              ;# not allowed, otherwise will exit programm before receive is called    
}

proc receive {s} {
  global OPTS
  if {[catch {read $s} line]} { puts "Error" ;  exit }
  puts "Received: <$line>"
}



tls::init -cafile $cafile -certfile $cert -keyfile $key
set s [tls::socket localhost 10002]

fconfigure $s -blocking 0 -buffersize 4096
fileevent  $s writable [list send $s ]                ;# when channel becomes writable
fileevent  $s readable [list receive $s]              ;# when channel becomes readable

vwait forever

