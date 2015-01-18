com! -nargs=* Collab py Collab.command(<f-args>)

python << EOF

import vim, json
import sys
sys.path.append("/System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/")

from twisted.internet.protocol import ClientFactory, Protocol
from twisted.internet import reactor
from threading import Thread

serv_path = vim.eval('expand("<sfile>:h")') + '/serv.py'

class CollabProtocol(Protocol):
    ''' Twisted Protocol for Collab '''
    def __init__(self, fact):
        self.fact = fact

    def send(self, change):
        self.transport.write(change)
    
    def data_received(self, data_string):
        packet = json.loads(data_string)
        data = packet['data']
        if packet['name'] != Collab.name and 'change_type' in packet.keys():
            if packet['change_type'] == "update_line":
                vim.current.buffer[packet['data']['line_num']] = packet['data']['updated_line']
            elif packet['change_type'] == "add_line":
                Collab.buff = vim.current.buffer[:packet['data']['line_num']] + \
                        packet['data']['new_line'] + vim.current.buffer[packet['data']['line_num']:]
                vim.current.buffer[:] = Collab.buff
            elif packet['change_type'] == 'remove_line':
                del vim.current.buffer[packet['data']['line_to_remove']]
            else:
                print "ERROR ERROR ERROR"
            vim.command(":redraw")

class CollabFactory(ClientFactory):
    ''' Twisted Factory for Collab '''
    def buildProtocol(self, addr):
        self.p = CollabProtocol()
        return self.p
    
    def start_factory(self):
        self.connected = True

    def stop_factory(self):
        self.connected = False

    def update_buf(self):
        data = {
            "data": {
                "cursor": {
                    "x": vim.current.window.cursor[1],
                    "y": vim.current.window.cursor[0]
                }
            },
            "name": Collab.name
        }
        cur_buff = vim.current.buffer[:]
        cur_line_num = vim.current.window.cursor[0]-1
        if len(cur_buff) == len(Collab.buff):
            data['change_type'] = 'update_line'
            data['data']['updated_line'] = cur_buff[cur_line_num]
            data['data']['line_num'] = cur_line_num
        elif len(cur_buff) > len(Collab.buff):
            data['change_type'] = 'add_line'
            data['data']['new_line'] = cur_buff[cur_line_num]
            data['data']['line_num'] = cur_line_num
        else:
            data['change_type'] = 'remove_line'
            data['data']['line_to_remove'] = cur_line_num + 1
        Collab.buff = cur_buff
        self.p.send(json.dump(data))

class CollabScope(object):
    ''' The scope of the plugin '''
    def initiate(self, addr, port, name):
        if hasattr(self, 'factory'):
            print "You are already connected"
            return
        port = int(port)
        if not hasattr(self, 'connection'):
            self.addr = addr
            self.port = port
            self.name = name
            self.buff = []
            self.factory = CollabFactory()
            self.connection = reactor.connectTCP(addr, port, self.factory)
            self.react_thread = Thread(target=reactor.run, args=(False,))
            self.react_thread.start()
        else:
            print "Restart Vim"

    def command(self, command, arg1=False, arg2=False, arg3=False):
        if command == "start":
            if arg1 and arg2:
                self.start_server(arg1, arg2)
            else:
                print "You must designate a port and name."
        elif command == "connect":
            if arg1 and arg2 and arg3:
                self.initiate(arg1, arg2, arg3)
            else:
                print "You must designate an address, port, and name."
        elif command == "quit":
            self.quit()
        elif command == "disconnect":
            self.disconnect()
        else:
            print "Please use start, connect, quit, or disconnect. See \
            docs for details."

    def start_server(self, port, name):
        vim.command(':silent execute "!'+CoVimServerPath+\
        ' '+port+' &>/dev/null &"')
        from time import sleep
        sleep(1)
        self.initiate('localhost', port, name)

    def quit(self):
        reactor.callFromThread(reactor.stop)

    def disconnect(self):
        if not self.connected:
            print "You must be connected to disconnect"
        else:
            reactor.callFromThread(self.connection.disconnect)

Collab = CollabScope()
EOF
