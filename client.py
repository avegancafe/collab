''' used for logging socket commands '''
import logging
logging.basicConfig(level=logging.DEBUG)

from socketIO_client import SocketIO

SIO = SocketIO('localhost', 3000)

def handle_send(*args):
    print(args[0])
SIO.emit('event', {"name": "Hello!"})
SIO.on('send', handle_send)
SIO.wait()
