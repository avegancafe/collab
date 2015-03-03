#!/usr/bin/python
''' The server for collab.vim '''

import json, argparse

from twisted.internet.protocol import Factory, Protocol
from twisted.internet import reactor
from time import sleep

PARSER = argparse.ArgumentParser(description='Start server.')
PARSER.add_argument('-p', '--persist', action='store_true', default=True,
                    help='Keep server running if all users disconnect')
PARSER.add_argument('port', type=int, nargs='?', default=8555,
                    help='Port number to run on')

USERS = {}

class React(Protocol):
    ''' protocol for server '''
    def __init__(self, factory):
        self.factory = factory

    def connectionMade(self):
        print "Connection Made"
        self.transport.write(json.dumps({
            'packet_type': 'initial',
            'data': {
                'buffer': self.factory.buff
                }
            }))

    def dataReceived(self, data):
        ''' handles data '''
        data = json.loads(data)
        print(data)
        if 'command' in data and data.get('command', '') == 'shut_down':
            print("Shutting down")
            reactor.stop()
            return
        elif 'packet_type' in data and not USERS and data['packet_type'] == 'handshake':
            USERS[data['name']] = self
            return
        elif 'change_type' in data:
            if data['change_type'] == 'add_line':
                self.factory.buff = self.factory.buff[:data['data']['line_num']] + \
                        [data['data']['new_line'].encode(),] + self.factory.buff[data['data']['line_num']:]
            elif data['change_type'] == 'update_line':
                self.factory.buff[data['data']['line_num']] = data['data']['updated_line']
            elif data['change_type'] == 'delete_line':
                del self.factory.buff[data['data']['line_to_remove']]
        if data['name'] not in USERS:
            d =  {
                "name": data['name'],
                "packet_type": "message",
                "data": {
                    'message_type': 'connect_success',
                    },
            }

            print "New user: %s"%data['name']
            if USERS:
                d['data']['buffer'] = self.factory.buff
            USERS[data['name']] = self
    	elif 'change_type' in data:
            d = {
                    "name": data['name'],
                    "packet_type": "update",
                    "change_type": data['change_type'],
                    "data": data['data']
                } 
        # print(d)
	# print(data)

        for user in USERS.keys():
            if user != data['name']:
                data_string = json.dumps(d)
                USERS[user].transport.write(data_string)
        return

class ReactFactory(Factory):
    ''' factory for server '''
    def __init__(self):
        USERS = set()
        self.buff = []
        self.port = 0

    def initiate(self, port):
        ''' initializes the factory '''
        self.port = port
        print 'Now listening on port {port}...'.format(port=port)
        reactor.listenTCP(port, self)
        reactor.run()

    def buildProtocol(self, addr):
        print("Building protocol")
        return React(self)

if __name__ == '__main__':
    args = PARSER.parse_args()
    Server = ReactFactory()
    Server.initiate(args.port)
