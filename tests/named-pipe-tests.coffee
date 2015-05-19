path = require 'path'

NamedPipe = require path.join(__dirname, '..')

expect = require('chai').expect

describe 'NamedPipe', ->
  describe 'Server', ->
    [server] = []

    it 'should take a pipe name as an argument and set the address', ->
      server = NamedPipe.listen('named-pipe-mocha')

      expect(server.pipeAddress).to.equal '\\\\.\\pipe\\named-pipe-mocha'
      server.listenPipe.close()

  describe 'Client', ->
    [server] = []

    beforeEach ->
      unless server
        server = NamedPipe.listen('named-pipe-mocha')

      if server
        server.removeAllListeners('connect')

    it 'should connect to the server', (done) ->
      server.on 'connect', ->
        done()

      client = NamedPipe.connect('named-pipe-mocha')

    it 'should support a chain of events', (done) ->
      server.on 'connect', (socket) ->
        socket.on 'message2', ->
          done()

        socket.send 'message1'

      client = NamedPipe.connect('named-pipe-mocha')
      client.on 'message1', ->
        client.send 'message2'

    it 'should not emit messages to other clients', (done) ->
      server.on 'connect', (socket) ->
        socket.on 'ping', ->
          socket.send 'pong'

      client1 = NamedPipe.connect('named-pipe-mocha')
      client2 = NamedPipe.connect('named-pipe-mocha')

      client1.on 'pong', ->
        done()

      client2.on 'pong', ->
        throw 'should not get'
        done()

      client1.send 'ping'
