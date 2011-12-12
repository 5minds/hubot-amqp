util = require 'util'
amqp = require 'amqp'

connection = amqp.createConnection({host: '127.0.0.1', vhost: '/development', login: 'guest', password: 'guest'})

connection.on 'ready', (conn) ->
  
  connection.queue 'reply-queue', autoDelete: true, (q) ->

    connection.exchange 'hubot topic', {type: 'topic'}, (ex) ->
      q.bind ex, q.name
      q.subscribe (msg) ->
        util.puts util.inspect msg
      ex.publish '', {question: 'hubot PING', user_name: "a user name"}, replyTo: q.name


