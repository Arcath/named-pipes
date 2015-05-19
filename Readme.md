# named-pipes

Easy to use IPC emitter using Windows Named Pipes.

## Installation

```
npm install named-pipes --save
```

## Usage

### Server

```coffee
NamedPipes = require 'named-pipes'

server = NamedPipes.listen('your-pipe-name')

server.on 'connect', (client) ->
  console.log 'New Client'

  client.send 'welcome', 'something' # THis gets passed to emit on the client side
```

### Client

```coffee
NamedPipes = require 'named-pipes'

pipe = NamedPipes.connect('your-pipe-name')

pipe.on 'welcome', (str) ->
  console.log str # Outputs 'something'
```
