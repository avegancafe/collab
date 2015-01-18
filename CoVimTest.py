''' The server for collab.vim '''

import json, argparse

from twisted.internet.protocol import Factory, Protocol
from twisted.internet import reactor

PARSER = argparse.ArgumentParser(description='Start server.')
PARSER.add_argument('-p', '--persist', action='store_true',
                    help='Keep server running if all users disconnect')
PARSER.add_argument('port', type=int, nargs='?', default=8555,
                    help='Port number to run on')

users = set()

class React(Protocol):
    def __init__(self, factory):
        self.factory = factory
        self.state = "GETNAME"

    def data_received(self, data):
        if data['name'] not in users:
            users.add(data['name'])

