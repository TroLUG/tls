


#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh8.3 "$0" ${1+"$@"}

package require tls

set dir             [file join [file dirname [info script]] certs]   ;# ./../tests/certs
set OPTS(-cafile)   [file join $dir ca.pem]
set OPTS(-cert)     [file join $dir server.pem]
set OPTS(-key)      [file join $dir server.key]

set OPTS(-port)    2468
set OPTS(-debug)   1
set OPTS(-require) 1

foreach {key val} $argv {
  if {![info exists OPTS($key)]} {
    puts stderr "Usage: $argv0 ?options?\
        \n\t-debug    boolean  Debugging on or off ($OPTS(-debug))\
        \n\t-cafile   file     Cert. Auth. File ($OPTS(-cafile))\
        \n\t-cert     file     Server Cert ($OPTS(-cert))\
        \n\t-key      file     Server Key ($OPTS(-key))\
        \n\t-require  boolean  Require Certification ($OPTS(-require))\
        \n\t-port     num      Port to listen on ($OPTS(-port))"
    exit
  }
  set OPTS($key) $val
}

# Catch  any background errors.
proc bgerror {msg} { puts stderr "BGERROR: $msg" }

# debugging helper code
proc shortstr {str} {
    #return "[string replace $str 10 end ...] [string length $str]b"
    return [string replace $str 10 end ...]
}



# ---------------------------------------------------------------------------
# As a response we just echo the data sent to us

proc respond {chan} {
  puts "Starting respond ..."
  if {[catch {read $chan} data]} {
    puts "respond: Error received on channel $chan ([shortstr $data]) ... Closing ..."
    catch {close $chan}
    return
  }
  
  #puts "respond: Data received: <[shortstr $data]>"
  puts "respond: Data received: <$data>"
  #if {$data != ""} { puts "got $chan ([shortstr $data])" }
  
  if {[eof $chan]} {
    # client gone or finished
    puts "respond: EOF receive on channel $chan ... Closing ..."
    close $chan        ;#  release the port
    return
  }
  
  # Return data: Header and body
  
  #set data "<html>1234567890</html>"   ;# ok
  set data "1234567890"                 ;# ok
  
  set len [string length $data]

  # Header
  set header ""
  append header "HTTP/1.1 200 OK\r\n"                        ;# mandatory
  #append header "Date: Tue, 12 Dec 2017 15:38:34 GMT\r\n"   ;# ok, but not needed
  #append header "Server: gws\r\n"                           ;# ok, but not needed
  
  append header "Content-Length: $len\r\n"                   ;# mandatory
  #append header "Content-Type: text/html;charset=UTF-8\r\n" ;# ok, but not needed
  #append header "Content-Encoding: br\r\n"                  ;# not ok  !!!!!!!!!!
  
  #append header "Connection:keep-alive\r\n"                 ;# ok
  append header "Connection: close\r\n"                      ;# Alternative: also ok


  set response "${header}\r\n${data}"
  puts "respond: returning <$response> ..."
  puts -nonewline $chan $response
  flush $chan
}




# ---------------------------------------------------------------------------
# Once connection is established, we need to ensure handshake.

proc handshake {s cmd} {
  puts "Starting handshake ..."
  if {[eof $s]} {
    puts "handshake: Received EOF on socket $s ... closing ..."
    close $s
  } elseif {[catch {tls::handshake $s} result]} {
    puts "handshake: error <$s>: result: <$result>"
  } elseif {$result == 1} {
    # Handshake complete
    puts "handshake: completely done (Socket: $s)"
    
    # waiting for more data to arrive, if so call proc $cmd
    fileevent $s readable [list $cmd $s]
  }

  after 1000
}


# ---------------------------------------------------------------------------
# Callback proc to accept a connection from a client.

proc accept { chan ip port } {
    puts "Starting accept ...   (IP: $ip, Port: $port)"
    puts "General Info: [info level 0] [fconfigure $chan]"
    fconfigure $chan -blocking 0
    fileevent $chan readable [list handshake $chan respond]
    puts "Closing accept ..."
}


# ---------------------------------------------------------------------------
# main

tls::init -cafile $OPTS(-cafile) -certfile $OPTS(-cert) -keyfile $OPTS(-key)
set chan [tls::socket -server accept -require $OPTS(-require) $OPTS(-port)]

puts "Server waiting connection on Channel $chan. Port $OPTS(-port)"
puts "Configuration: [fconfigure $chan]"

vwait __forever__
