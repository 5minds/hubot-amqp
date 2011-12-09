util = require 'util'
amqp = require 'amqp'

connection = amqp.createConnection({host: '127.0.0.1', vhost: '/development', login: 'guest', password: 'guest'})

connection.on 'ready', (conn) ->
  
  connection.queue 'reply-queue', autoDelete: true, (q) ->

    connection.exchange 'reply-topic', autoDelete: true, type: 'topic', (ex2) ->
      q.bind ex2, q.name
      q.subscribe (msg) ->
        util.puts util.inspect msg

    connection.exchange 'hubot topic', {type: 'topic'}, (ex) ->
      ex.publish '', {question: 'hubot PING'}, replyTo: q.name


