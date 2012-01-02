util = require 'util'
amqp = require 'amqp'


OptParse = require 'optparse'

Switches = [
  [ "-h", "--help",            "Display the help information" ],
  [ "-m", "--message message", "What message should ne used for send to hubot via amqp" ]
]

Options =
  message: "PING"

Parser = new OptParse.OptionParser(Switches)
Parser.banner = "Usage hubot [options]"

Parser.on "help", (opt, value) ->
  console.log Parser.toString()
  process.exit 0

Parser.on "message", (opt, value) ->
  Options.message = value

Parser.parse process.argv


connection = amqp.createConnection({host: '127.0.0.1', vhost: '/development', login: 'guest', password: 'guest'})

connection.on 'ready', (conn) ->
  
  connection.queue 'reply-queue', autoDelete: true, (q) ->

    connection.exchange 'hubot topic', {type: 'topic'}, (ex) ->
      q.bind ex, q.name
      q.subscribe (msg) ->
        util.puts msg.answer
        process.exit 0

      ex.publish '', {question: 'hubot ' + Options.message, user_name: "a user name"}, replyTo: q.name


