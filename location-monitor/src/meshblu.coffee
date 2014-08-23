skynet = require 'skynet'
url    = require 'url'

class Meshblu
  constructor: (uuid, token, uri, callback=->) ->
    {protocol, hostname, port} = url.parse(uri)

    @connection = skynet.createConnection
      protocol: protocol
      server: hostname
      port: port ? 80
      uuid: uuid
      token: token
    @connection.on 'ready', callback

  close: =>
    @connection.close()

  onMessage: (callback=->) =>
    @connection.on 'message', callback

module.exports = Meshblu
