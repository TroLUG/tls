package require http
package require tls


set dir            [file join [file dirname [info script]] certs]
set OPTS(-cafile)  [file join $dir ca.pem]
set OPTS(-cert)    [file join $dir client.pem]
set OPTS(-key)     [file join $dir client.key]


http::register https 443 tls::socket

tls::init -cafile $OPTS(-cafile) -certfile $OPTS(-cert) -keyfile $OPTS(-key)

#set url "https://encrypted.google.com"
set url "https://localhost:2468"


set token [::http::geturl $url -timeout 30000]
#set token [::http::geturl $baseURL/$chat/delete -method POST -timeout 15000 -keepalive 1]

set status [::http::status $token]

upvar #0 $token state
if {$state(status) == "timeout" } {
    puts  "Timeout (no response from Server)" 
} elseif {$state(status) == "ok" }  {
    puts  "Body = <$state(body)>"
} else {
    puts "Received unhandled state <$state(status)>"
}


set answer [http::data $token]


http::cleanup $token
http::unregister https

puts "Data = <$answer>"
puts "Status = $status"

