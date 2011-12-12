util = require 'util'
amqp = require 'amqp'

connection = amqp.createConnection({host: '127.0.0.1', vhost: '/development', login: 'guest', password: 'guest'})

connection.on 'ready', (conn) ->
  connection.exchange 'hubot topic', {type: 'topic'}, (ex) ->
    connection.queue 'hubot-subscribe', durable: true, passive: false, autoDelete: false, (q) ->
      util.puts 'queue ' + q.name + ' ready'

      q.bind ex, '#'
      
      q.subscribe (msg, headers, deliveryInfo) ->
        util.puts util.inspect msg
        util.puts util.inspect headers
        util.puts util.inspect deliveryInfo

        connection.exchange 'reply-topic', autoDelete: true, type: 'topic', (ex2) ->
          util.puts 'exchange for reply ' + deliveryInfo.replyTo
          ex2.publish deliveryInfo.replyTo, {answer: 'Answer for: ' + msg.question}



