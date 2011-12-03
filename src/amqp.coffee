Robot   = require("hubot").robot()
Adapter = require("hubot").adapter()


class Amqp extends Adapter
  constructor: (robot) ->
    @exchange_name   = process.env.HUBOT_AMQP_EXCHANGE_NAME || 'hubot topic'
    @exchane_type = process.env.HUBOT_AMQP_EXCHANGE_TYPE || 'topic'
    @queue_name  = process.env.HUBOT_AMQP_QUEUE_NAME || 'hubot_listener'
    @amqp_hostname = process.env.HUBOT_AMQP_HOSTNAME || 'localhost'
    @amqp_port = process.env.HUBOT_AMQP_PORT || 5672
    @amqp_login = process.env.HUBOT_AMQP_LOGIN || 'guest'
    @amqp_passwd = process.env.HUBOT_AMQP_PASSWD || 'guest'
    @amqp_vhost = process.env.HUBOT_AMQP_VHOST || '/'

    super robot

  send: (user, strings...) ->

    # publish the answer
    
    ''
  
  reply: (user, strings...) ->
    @send user, str for str in strings

  run: ->

    # connect to rabbit ?!? -> constructor
    
    # create a exchange
    
    # create a queue
    
    # subscribe to message


    ''

