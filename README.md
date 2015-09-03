# collab
lol vim is gr9

A collaborative plugin for vim. To use, install pathogen and clone this repo to your ~/.vim/bundle directory.

## Usage

`:Collab start <port> <name>`

`:Collab connect <host> <port> <name>`

`:Collab disconnect`

`:Collab quit`

## Examples

`:Collab start 8000 Kyle`

This command will start a server on port 8000 and connect you with the name of Kyle.

`:Collab connect 192.168.0.1 8000 Kyle`

This command will connect to an already running server at `192.168.0.1:8000` with the name Kyle.

## Status 

Currently you have to start the server manually. To do this, do the following:

```
chmod +x serv.py
./serv.py
```

This starts the server. You can optionally specify a port number by using -p=<port> as an option, but it defaults to port 8555. You can connect to this server as usual with :Collab connect localhost 8555 Kyle, assuming it is on port 8555.
