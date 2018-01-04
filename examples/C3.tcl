# client: http without TLS (GET and POST request)

package require http

set url "http://localhost:10003"

set token  [http::geturl $url -timeout 30000]
set state  [http::status $token]
set answer [http::data $token]
puts "Received Data   = <$answer>"
puts "Received Status = <$state>"

http::cleanup $token

puts "\n\n"

# -----------------------------------------------------

set post_data "par1=20\npar2=50"
set token [http::geturl $url -method POST -query $post_data  -timeout 30000 -keepalive 1 -type application/json]
set state [http::status $token]
set answer [http::data $token]
puts "Received Data   = <$answer>"
puts "Received Status = <$state>"


