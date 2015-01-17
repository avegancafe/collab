''' used for logging socket commands '''
import logging
logging.basicConfig(level=logging.DEBUG)

from socketIO_client import SocketIO

socketIO = SocketIO('localhost', 3000)

socketIO.emit('aaa')

