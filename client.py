''' used for logging socket commands '''
import logging
logging.basicConfig(level=logging.DEBUG)

from socketIO_client import SocketIO

SIO = SocketIO('localhost', 3000)

SIO.emit('aaa')

