function! Init() {

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

function! Connect(cur_hash) {
python << EOF

import vim, urllib2
from socketIO_client import SocketIO, BaseNamespace

import logging
logging.basicConfig(level=logging.DEBUG)

SIO = SocketIO('localhost', 3000)
SIO.define(BaseNamespace, '/'+cur_hash)
cur_pending = urllib2.urlopen('localhost:3000/getpending?cur=%s'%cur_hash).read()
cur_approved = urllib2.urlopen('localhost:3000/getapproved?cur=%s'%cur_hash).read()

vim.command("let s:pending = "+cur_pending)
vim.command("let s:approved = "+cur_approved)
EOF
}

function! Approve(name) {
python << EOF

EOF
}
