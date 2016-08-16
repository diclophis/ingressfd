#

class Endpoint
  def initialize
    tls_server = Tls::Server.new(key_file: 'private-key.pem', cert_file: 'server.pem')

    s = UV::TCP.new
    s.bind(UV::ip4_addr('127.0.0.1', 30001))
    $stdout.write "bound to #{s.getsockname}"

    s.listen(5) do |x|
      return if x != 0
      tcp_client = s.accept

      $stdout.write "connected (peer: #{tcp_client.getpeername})"

      phr = Phr.new

      ss = String.new

      tcp_client.read_start { |b|
        bb = b.to_s
        ss += bb

        offset = phr.parse_request(ss)

        if offset.is_a?(Fixnum) && bb.length != 0
          #case phr.path
          $stdout.write(phr.headers.inspect)
        elsif offset == :parser_error
          $stdout.write :closed
          tcp_client.shutdown
        end
      }

=begin
      pipe = 

      tls_client = tls_server.accept_socket tcp_client.fileno


      until tcp_client.readable? && tcp_client.writable?
        $stdout.write(".")
      end

      #$stdout.write(tls_client.handshake.inspect)

      #tls_client.write "hallo\n"
      #tls_client.close
      #tls_client.read
=end
    end
  end

  def index
  @index ||= <<EOJS
    <!DOCTYPE html>
    <html>
      <head>
        <link rel='icon' href='data:;base64,iVBORw0KGgo='>
        <style>html, body { background: black; margin: 0; padding: 0; }</style>
        <script></script>
      </head>
      <body>
        <h1>ingressfd</h1>
      </body>
    </html>
EOJS

  end
end
