
####################################################
#
#   Antidote Gameplay Event Listener
#
#   This UDP server will listen for events on
#   port 5000.
#
#   Netcat UDP Server:  nc -u -l -p 5000 
#   Netcat UDP Client:  nc -u localhost 5000
#
####################################################

import sys
import time,datetime
import socket
import random
import json

####################################################
# Config
####################################################

config = {
    'host': "0.0.0.0", #socket.gethostbyname(container_name),
    'port': 5000
}

print('[ DEBUG ] UDP Listener Running on {}.{}'.format(config['host'],config['port']))

####################################################
# Functions
####################################################

def udp_listen(ip_addr, port):
    
    bufferSize  = 1024
    
    # Create a datagram socket
    UDPServerSocket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
    
    # Bind to address and ip
    UDPServerSocket.bind((ip_addr, port))
    
    while True:
        
        bytesAddressPair = UDPServerSocket.recvfrom(bufferSize)
        
        message = bytesAddressPair[0]
        address = bytesAddressPair[1]
        
        clientMsg = "Message from Client: {}".format(message)
        clientIP  = "Client IP Address:   {}".format(address)
        
        print(clientMsg)
        print(clientIP)
        
        # Sending a reply to client
        #UDPServerSocket.sendto(str.encode(bytesToSend, address)


def send_udp(socket_udp_obj, host, port, payload):
    try:
        if type(payload) is dict:
            payload = json.dumps(payload).encode('utf-8')
        else:
            payload = '{}'.format(payload).encode('utf-8')
        
        #socket_udp_obj = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        socket_udp_obj.sendto(payload,(host,port))
        print('[ INFO ] UDP payload: {}'.format(payload))
        #socket_udp_obj.close()
    except Exception as e:
        print('[ EXCEPTION ] {}'.format(e))



####################################################
# Main
####################################################

def main():
    
    '''
    # TCP Connection
    try:
        host = simulator_config['host']
        port = simulator_config['port']
        socket_tcp_obj = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        socket_tcp_obj.connect((host, port))
        while True:
            time.sleep(random.random()*2)
            
            payload = {
                'score': random.random()
            }
            
            send_tcp(socket_tcp_obj, payload)
    except Exception as e:
        print('[ EXCEPTION ] {}'.format(e))
        sys.exit()
    '''
    
    # UDP Connection
    try:
        host = simulator_config['host']
        port = simulator_config['port']
        socket_udp_obj = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        while True:
            time.sleep(random.random()*2)
            
            payload = {
                'eventid':      int(random.random()*10000000),
                'game_server':  socket.gethostname(),
                'game_type':    'Capture The Flag',
                'game_map':     'Volcano',
                'event_datetime': datetime.datetime.now().strftime('%Y%m%d_%H%M%S_%f'),
                'player':       get_player(),
                'killed':       random.randint(0,1),
                'x_cord':       random.random()*100,
                'y_cord':       random.random()*100,
                'score':        random.randint(1,100)
            }
            
            send_udp(socket_udp_obj, host, port, payload)
    except Exception as e:
        print('[ EXCEPTION ] {}'.format(e))
        sys.exit()


main()


#ZEND