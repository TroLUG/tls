#!/usr/bin/tclsh
# client: https (http and TLS)   (POST request)

# Do the test as follows:
# - start server:    tclsh S7.tcl -wt 5000          (wait 5 sec before returning response)
# - start 2 clients at the same time:
#   * tclsh C7.tcl  -pd "100+16" &
#   * tclsh C7.tcl  -pd "200+8" &
#
# -->   Result: The server starts 2 threads immediately, computes result very fast, but delay answer for 5 sec
#               The different math operations show that the server works in parallel before the answer is returned


package require http
package require tls
package require cmdline

set dir     [file join [file dirname [info script]] certs]
set cafile  [file join $dir ca.pem]
set cert    [file join $dir client.pem]
set key     [file join $dir client.key]


  # -----------------------------------------------------------------------------------
  proc usage { } {
    puts { \nusage: tclsh client.tcl <options>

    -n  <num>          number of loops
    -pd <postdata>     postdata: operation to send to server, e.g. "5+3"
    }
  }  

  # -----------------------------------------------------------------------------------
  # main
  
  set options {
    {h                            "help" }
    {n.arg         1              "number of loops"}
    {pd.arg        100+           "postdata to send to server, e.g. 5+3"}
  }

  array set arg [cmdline::getoptions argv $options]
  #puts "Options:" ; foreach item [array names arg] {puts "  $item: $arg($item)"}

  if { $arg(h) } { usage;  exit}
  
  

  http::register https 443 tls::socket
  tls::init -cafile $cafile -certfile $cert -keyfile $key


  set pd $arg(pd)
  set num       $arg(n)

  set url "https://localhost:10005"

  #for {set i 0} {$i < $num} {incr i} {
    #A: set token [http::geturl $url -method POST -query $post_data  -timeout 30000 -keepalive 1]
    #B: set token [http::geturl $url -method POST -query $post_data  -timeout 30000 -keepalive 1 -type application/json]
    #                      Option -type sets the value of header element Content-Type
  
    set post_data ${pd}
    set token [http::geturl $url -method POST -query $post_data  -timeout 30000 -keepalive 1 -type application/json]

    set state [http::status $token]
    set answer [http::data $token]
    
    puts "\n$post_data --> $answer         (State: $state)"

    http::cleanup $token
  #}

  http::unregister https
  exit
