import socket
import json
import base64
import os
import urllib.request
import time

def get_page_ws():
    with urllib.request.urlopen("http://127.0.0.1:9222/json") as r:
        pages = json.loads(r.read().decode())
        for p in pages:
            if p.get("type") == "page" and "devtools/page" in p.get("webSocketDebuggerUrl", ""):
                return p["webSocketDebuggerUrl"]
    return None

class SimpleWS:
    def __init__(self, ws_url):
        parts = ws_url[5:].split("/", 1)
        host_port = parts[0].split(":")
        self.host = host_port[0]
        self.port = int(host_port[1])
        self.path = "/" + parts[1]
        self.sock = socket.create_connection((self.host, self.port), timeout=10)
        self._handshake()
        self.msg_id = 0

    def _handshake(self):
        key = base64.b64encode(os.urandom(16)).decode()
        req = (
            f"GET {self.path} HTTP/1.1\r\n"
            f"Host: {self.host}:{self.port}\r\n"
            f"Upgrade: websocket\r\n"
            f"Connection: Upgrade\r\n"
            f"Sec-WebSocket-Key: {key}\r\n"
            f"Sec-WebSocket-Version: 13\r\n\r\n"
        )
        self.sock.sendall(req.encode())
        res = self.sock.recv(4096).decode(errors='ignore')
        if "101" not in res:
            raise RuntimeError(f"WS Handshake failed: {res}")

    def send_cmd(self, method, params=None):
        self.msg_id += 1
        cid = self.msg_id
        msg = {"id": cid, "method": method}
        if params:
            msg["params"] = params
        payload = json.dumps(msg).encode('utf-8')
        length = len(payload)
        header = bytearray([0x81])
        mask_key = os.urandom(4)
        if length < 126:
            header.append(0x80 | length)
        elif length < 65536:
            header.append(0x80 | 126)
            header.extend(length.to_bytes(2, 'big'))
        else:
            header.append(0x80 | 127)
            header.extend(length.to_bytes(8, 'big'))
        masked = bytearray([b ^ mask_key[i % 4] for i, b in enumerate(payload)])
        self.sock.sendall(header + mask_key + masked)
        return cid

    def recv_cmd(self, target_id):
        buf = bytearray()
        while True:
            chunk = self.sock.recv(65536)
            if not chunk:
                break
            buf.extend(chunk)
            while len(buf) >= 2:
                b1 = buf[0]
                b2 = buf[1]
                masked = (b2 & 0x80) != 0
                plen = b2 & 0x7F
                idx = 2
                if plen == 126:
                    if len(buf) < 4:
                        break
                    plen = int.from_bytes(buf[2:4], 'big')
                    idx = 4
                elif plen == 127:
                    if len(buf) < 10:
                        break
                    plen = int.from_bytes(buf[2:10], 'big')
                    idx = 10
                mask = None
                if masked:
                    if len(buf) < idx + 4:
                        break
                    mask = buf[idx:idx+4]
                    idx += 4
                if len(buf) < idx + plen:
                    break
                payload = buf[idx:idx+plen]
                buf = buf[idx+plen:]
                if masked:
                    payload = bytearray([b ^ mask[i % 4] for i, b in enumerate(payload)])
                txt = payload.decode('utf-8', errors='ignore')
                try:
                    obj = json.loads(txt)
                    if obj.get("id") == target_id:
                        return obj
                except Exception:
                    pass

    def navigate(self, url):
        cid = self.send_cmd("Page.navigate", {"url": url})
        self.recv_cmd(cid)
        time.sleep(2)

    def eval_js(self, js_expr):
        cid = self.send_cmd("Runtime.evaluate", {"expression": js_expr, "returnByValue": True})
        return self.recv_cmd(cid)

    def screenshot(self, out_path):
        cid = self.send_cmd("Page.captureScreenshot", {"format": "png"})
        resp = self.recv_cmd(cid)
        img_b64 = resp["result"]["data"]
        with open(out_path, "wb") as f:
            f.write(base64.b64decode(img_b64))
        print(f"Captured: {out_path}")

def run():
    ws_url = get_page_ws()
    ws = SimpleWS(ws_url)
    ws.send_cmd("Page.enable")
    ws.send_cmd("Runtime.enable")

    # Open citareservada and open modal
    ws.navigate("http://localhost:8080/ArtDent/citareservada.jsp?codigo=ART-RES-00014&precio=100.00&nombre=Camila%20Silva&dni=75667788")
    time.sleep(1)
    ws.eval_js("new bootstrap.Modal(document.getElementById('modalPagarEnLinea')).show()")
    time.sleep(1)
    ws.screenshot("pasarela_modal_ui.png")

if __name__ == "__main__":
    run()
