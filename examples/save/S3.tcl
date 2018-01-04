# server: http without TLS



proc Accept {s addr port} {
    fconfigure $s -buffering line
    fileevent $s readable [list Read $s]
}


proc Read {s} {

  # proc read does not work, because no EOF is sent by client C3 using method http::geturl

  set len 0; set postdata ""
  while {1} {    
    if { [catch {gets $s line}] } { puts "Read: Error"; return }
    if { [eof $s] }               { puts "Read: EOF";  after 500; return } 
  
    #puts "Received: <$line>"
    if {[string match "Content-Length:*" $line]} {
      set len [string range $line 16 end]
      #puts "got content length: $len"
    }
    if {$line == ""} {break}
  }
    
  if {$len != 0} {
    set postdata [read $s $len]
    #puts "Received: Postdata=<$postdata>"
  }
  
  Respond $s $postdata
}


proc Respond {s postdata} {
  #puts "Starting respond: postdata=<$postdata>"
  if {$postdata == ""} {set postdata "no POST request"}
  set data "Received Post-Data: $postdata"

  #set delim "\r\n"          ;# does not work
  set delim "\n"
  
  set     header "HTTP/1.1 200 OK$delim"
  append header "Content-Length: [string length $data]$delim"
  #append header "Connection:keep-alive$delim"                 ;# ok
  append header "Connection: close$delim"

  set response "${header}${delim}$data$delim"
  puts "Returning: <$data> ..."
  puts -nonewline $s $response
  flush $s
}


# main
set s [socket -server Accept 10003]
vwait forever
