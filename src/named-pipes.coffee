crypto = require 'crypto'
EventEmitter = require('events').EventEmitter
net = require 'net'

module.exports =
  listen: (pipeName) ->
    new PipeEmitter(pipeName, false, true)

  connect: (pipeName) ->
    new PipeEmitter(pipeName, true, true)

class PipeEmitter extends EventEmitter
  clients: {}

  constructor: (@pipeName, @listenOnSub, @listen) ->
    super

    @pipeAddress = "\\\\.\\pipe\\#{@pipeName}"

    if @listenOnSub
      hash = crypto.createHash('sha1')
      hash.update(process.hrtime().toString())
      @subKey = hash.digest('hex')

    @listenToPipe() if @listen

  listenToPipe: ->
    @listenPipe = net.createServer (stream) => @createStream(stream)

    if @listenOnSub
      @send 'npmsg:connect-to-subkey', @subKey
      @listenPipe.listen @pipeAddress + "-" + @subKey
    else
      @listenPipe.listen @pipeAddress

  createStream: (stream) ->
    stream.on 'data', (str) => @handleWrite(str)

  handleWrite: (str) ->
    obj = JSON.parse(str.toString())

    obj.arguments.unshift(obj.event)

    if obj.subKey
      @handleMessageFromClient(obj)
    else
      @emit.apply this, obj.arguments

  send: (event, args...) ->
    obj = {
      event: event
      arguments: args
    }

    obj.subKey = @subKey if @subKey
    
    pipe = net.connect(@pipeAddress)
    pipe.write(JSON.stringify(obj))
    pipe.end()

  handleMessageFromClient: (obj) ->
    unless @clients[obj.subKey]
      @clients[obj.subKey] = new PipeEmitter(@pipeName + "-" + obj.subKey, false, false)

    if obj.event == 'npmsg:connect-to-subkey'
      @emit 'connect', @clients[obj.subKey]
    else
      @clients[obj.subKey].emit.apply(@clients[obj.subKey], obj.arguments)
