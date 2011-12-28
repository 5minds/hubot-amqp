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

    console.log("answer : " + answer + " to user " + user)

    # publish the answer
    @exchange.publish(user.reply_to, {answer: answer})

  
  reply: (user, strings...) ->

    console.log("reply: " + user + " with " + stings.join(', '))

    @send user, str for str in strings

  run: ->
    # connect to rabbit ?!? -> constructor
    @connection = amqp.createConnection({host: @amqp_hostname
    , port: @amqp_port
    , vhost: @amqp_vhost
    , login: @amqp_login
    , password: @amqp_passwd})

    # create a exchange
    @connection.on 'ready', () =>

      #console.log("conn: " + util.inspect(@connection))

      @connection.exchange @exchange_name, type: 'topic', (exch) =>
        console.log('Exchange ' + exch.name + ' ready')
        @exchange = exch

        # create a queue
        @connection.queue 'hubot-listener', durable: false, (queue) =>
          console.log('Queue ' + queue.name + ' ready')
          queue.bind exch, '#'

          # subscribe to message
          queue.subscribe (msg, headers, deliveryInfo) =>
            console.log(msg.question)
      
            user = @userForId '1', name: msg.user_name, reply_to: deliveryInfo.replyTo

            message = new Robot.TextMessage user, msg.question

            @receive message

exports.use = (robot) ->
  new Amqp robot

