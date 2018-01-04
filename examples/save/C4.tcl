# client: https to internet (google)

package require http
package require tls


http::register https 443 tls::socket


set url "https://encrypted.google.com"
set token [http::geturl $url -timeout 30000]

set state [http::status $token]
set answer [http::data $token]
puts "Data = <$answer>"
puts "State = $state"

http::cleanup $token

# -----------------------------------------------------
puts "Continue with any key"
gets stdin weiter


set url "https://encrypted.google.com"
set token [http::geturl $url -timeout 30000]

set state [http::status $token]
set answer [http::data $token]
puts "Data = <$answer>"
puts "State = $state"


http::unregister https


