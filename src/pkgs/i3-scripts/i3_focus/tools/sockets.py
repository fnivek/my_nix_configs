import socket
import json


class Sockets:
    def __init__(self, socket_file):
        self._socket_file = socket_file
        self._client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

    def get_containers_history(self):
        self._client.connect(self._socket_file)
        # The server closes the connection after the reply, which can exceed one recv().
        chunks = []
        while chunk := self._client.recv(4096):
            chunks.append(chunk)
        self._client.close()
        return json.loads(b''.join(chunks).decode())

    def _send_cmd(self, cmd):
        self._client.connect(self._socket_file)
        n_sent = 0
        while n_sent < len(cmd):
            n_writen = self._client.send(cmd[n_sent:])
            if n_writen == 0:
                raise RuntimeError(f"Lost connection to {self._socket_file}")
            n_sent += n_writen
        self._client.close()

    def next(self):
        self._send_cmd(b'next')

    def last(self):
        self._send_cmd(b'last')