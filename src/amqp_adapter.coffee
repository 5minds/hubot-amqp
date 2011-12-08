util = require('util')
amqp = require('amqp')

Robot   = require("hubot").robot()
Adapter = require("hubot").adapter()

class Amqp extends Adapter
  constructor: (robot) ->
    @exchange_name = process.env.HUBOT_AMQP_EXCHANGE_NAME || 'hubot topic'
    
    @amqp_hostname = process.env.HUBOT_AMQP_HOSTNAME || '127.0.0.1'
    @amqp_port = process.env.HUBOT_AMQP_PORT || 5672
    @amqp_login = process.env.HUBOT_AMQP_LOGIN || 'guest'
    @amqp_passwd = process.env.HUBOT_AMQP_PASSWD || 'guest'
    @amqp_vhost = process.env.HUBOT_AMQP_VHOST || '/development'

    super robot

  send: (user, strings...) ->
    answer = strings.join "\n"

    # publish the answer
    @exchange.publish(user, {answer: answer})

  
  reply: (user, strings...) ->
    @send user, str for str in strings

  run: ->
    # connect to rabbit ?!? -> constructor
    @connection = amqp.createConnection({
      host: @amqp_hostname,
      vhost: @amqp_vhost,
      login: @amqp_login,
      password: @amqp_passwd})

    console.log(util.inspect(@connection))
    
    # create a exchange
    @connection.on 'ready', (conn) ->
      conn.exchange @exchange_name, type: 'topic', durable: true, (exch) ->
        console.log('Exchange ' + exchange.name + ' ready')
        @exchange = exch

        # create a queue
        @connection.queue 'hubot-listener', durable: false, (queue) ->
          console.log('Queue ' + queue.name + ' ready')
          queue.bind exch, '#'

          # subscribe to message
          queue.subscribe (msg, headers, deliveryInfo) ->
            console.log(util.inspect(msg))
            console.log(util.inspect(headers))
            console.log(util.inspect(deliveryInfo))

            @receive new Robot.TextMessage deliveryInfo.replyTo, msg.question

exports.use = (robot) ->
  new Amqp robot

