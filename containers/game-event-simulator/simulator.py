
####################################################
#
#   Events Simulator
#
#   This simulator will randomly generate events,
#   at randomized intervals, on user-defined port.
#
#   Netcat listen to UDP Traffic (used for debugging)
#   netcat -ul -p 5000
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

ensemble_container = 'game_event_simulator'

simulator_config = {
    'host': "0.0.0.0", #socket.gethostbyname(ensemble_container),
    'port': 5000
}

print('[ DEBUG ] Ensemble Container Host: {}'.format(simulator_config['host']))

####################################################
# Functions
####################################################

def send_tcp(socket_tcp_obj, payload):
    try:
        if type(payload) is dict:
            payload = json.dumps(payload).encode('utf-8')
        else:
            payload = '{}'.format(payload).encode('utf-8')
        
        #socket_tcp_obj = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        #socket_tcp_obj.connect((host, port))
        socket_tcp_obj.sendall(payload)
        print('[ INFO ] TCP payload: {}'.format(payload))
        #socket_tcp_obj.close()
    except Exception as e:
        print('[ EXCEPTION ] {}'.format(e))
    return None


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
    return None


def get_player():
    return random.choice([
        'Mickey',
        'Minnie',
        'Snoopy',
        'Mickey',
        'Bart',
        'Belle',
        'Elsa',
        'Betty'
    ])


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