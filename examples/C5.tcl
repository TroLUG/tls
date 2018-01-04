#!/usr/bin/tclsh
# client: https (http and TLS)    (GET and POST request)


package require http
package require tls

set dir     [file join [file dirname [info script]] certs]
set cafile  [file join $dir ca.pem]
set cert    [file join $dir client.pem]
set key     [file join $dir client.key]


http::register https 443 tls::socket
tls::init -cafile $cafile -certfile $cert -keyfile $key

set url "https://localhost:10005"
set post_data "par1=20\npar2=50"

# -----------------------------------------------------
# Get request

set token [http::geturl $url -timeout 30000]
set state [http::status $token]
set answer [http::data $token]
puts "Data = <$answer>"
puts "State = $state"

http::cleanup $token
puts "\n\n"

# -----------------------------------------------------


#A: set token [http::geturl $url -method POST -query $post_data  -timeout 30000 -keepalive 1]
#B: set token [http::geturl $url -method POST -query $post_data  -timeout 30000 -keepalive 1 -type application/json]
#                      Option -type sets the value of header element Content-Type

set token [http::geturl $url -method POST -query $post_data  -timeout 30000 -keepalive 1 -type application/json]
set state [http::status $token]
set answer [http::data $token]
puts "Data = <$answer>"
puts "State = $state"

http::cleanup $token



http::unregister https
exit

