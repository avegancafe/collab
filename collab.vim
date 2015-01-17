function! init() {

python << EOF
import vim, urllib2
from socketIO_client import SocketIO, BaseNamespace

import logging
logging.basicConfig(level=logging.DEBUG)

cur_hash = urllib2.urlopen("localhost:3000/newhash").read()

SIO = SocketIO('localhost', 3000)
SIO.define(BaseNamespace, '/'+cur_hash)

vim.command("let s:pending = []")
vim.command("let s:approved = []")


EOF
}
