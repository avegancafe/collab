''' The server for collab.vim '''

import json, argparse

from twisted.internet.protocol import Factory, Protocol
from twisted.internet import reactor

PARSER = argparse.ArgumentParser(description='Start server.')
PARSER.add_argument('-p', '--persist', action='store_true',
                    help='Keep server running if all users disconnect')
PARSER.add_argument('port', type=int, nargs='?', default=8555,
                    help='Port number to run on')

USERS = set()

class React(Protocol):
    ''' protocol for server '''
    def __init__(self, factory):
        self.factory = factory
        self.state = "GETNAME"

    def data_received(self, data):
        ''' handles data '''
        if data['name'] not in USERS:
            USERS.add(data['name'])
        for _ in range(len(USERS)):
            data_string = json.dumps(data)
            self.transport.write(data_string)
        return

class ReactFactory(Factory):
    ''' factory for server '''
    def __init__(self):
        self.buff = []
        self.port = 0

    def initiate(self, port):
        ''' initializes the factory '''
        self.port = port
        print 'Now listening on port {port}...'.format(port=port)
        reactor.listenTCP(port, self)
        reactor.run()

    def buildProtocol(self, addr):
        return React(self)

if __name__ == '__main__':
    args = PARSER.parse_args()
    Server = ReactFactory()
    Server.initiate(args.port)
