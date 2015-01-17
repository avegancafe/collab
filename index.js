var express = require('express'),
    app = express(),
    server = require('http').createServer(app),
    sio = require('socket.io'),
    port = process.env.PORT || 3000;

server.listen(port, function () {
    console.log('Server is listening at port %d', port);
});

//app.use(express.static(__dirname + '/public'));
io = sio.listen(server)

io.on('connection', function (socket) {
    console.log('new user conencted');
    socket.emit('send', {'a': 100, 'b': 200})
    socket.on('event', function (data) {
        console.log('aaa');
        console.log(data.name);
    });
});
