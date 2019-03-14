import sys
import os
import asyncio
import atexit
import json
import time

import serverinfo
from clientinfo import Client

client_list = []

def checkservername(name): #Exits if server is not valid
    if name not in serverinfo.server_boiz:
        print("Please use a valid server name: " + str(serverinfo.server_boiz), file = sys.stderr)
        sys.exit(1)
    return

def close_logfile(): # Closes the logfile file descriptor
    logfile_fd.close()
    print("PROXY: File closed")
    return

def format(stri): # Formats incoming command into a list
    stri = stri.rstrip().strip().split()
    return stri

async def to_writer(writer, say): # Writes say into StreamWriter writer
    say = say.encode()
    writer.write(say)
    await writer.drain()
    writer.close()
    return

# Future documentation: https://docs.python.org/3/library/asyncio-eventloop.html#creating-futures-and-tasks
async def client_handler(reader, writer):
    # Grab lines from reader
    # StramReader documentation : https://docs.python.org/3/library/asyncio-stream.html#asyncio.StreamReader
    holdme = await reader.readline()
    # POSIX Time: https://docs.python.org/3/library/time.html
    received_time = time.time()
    print("PROXY: " + str(received_time))
    holdme = holdme.decode()
    logfile_fd.write('Received: ' + str(holdme) + '\n') #TODO: Format this, thanks
    logfile_fd.flush() # Fixes writing to file out of order bug

    command = format(holdme)
    if (not command):
        print("PROXY: Bad message")
        await to_writer(writer, "Bad message: " + holdme)
        logfile_fd.write('Bad message: ' + str(holdme) + '\n') #TODO: Format this, thanks
        return
    if (command[0] == "IAMAT"):
        print("PROXY: IAMAT command received")
        # Check valid arguments for command
        if (len(command) != 4):
            print("Please use the IAMAT command in the following manner: IAMAT [client-id] [ISO6709-location] [POSIX-time]", file = sys.stderr)
            sys.exit(1)
        client = Client(command[1], command[2], command[3])
        client_list.append(client)
        time_change = received_time - float(command[3])
        if (time_change >= 0):
            pos = "+"
        else:
            pos = "-"
        await to_writer(writer, "AT " + name + " " + pos + str(time_change) + " " + client.id + " " + client.loc + " " + client.clock + '\n')
        
    #TODO: Handle WHATSAT
        
    return

def main():
    # Global variables so that I don't have to pass them everytime mb
    global name
    global logfile
    global logfile_fd
    # Handle arguments
    if (len(sys.argv) != 2):
        print("Please use this program in the following format: python3 server.py [server-name]", file = sys.stderr)
        sys.exit(1)

    # Set server name
    name = sys.argv[1]
    checkservername(name)

    #Get port number
    port_num = serverinfo.server_portnums[name]
    print("PROXY: Port number: " + str(port_num))
    
    # Open log file
    logfile = name + ".txt"
    # Try documentation: https://docs.python.org/3/tutorial/errors.html
    # Remove file if it's there
    try:
        os.remove(logfile)
    except FileNotFoundError:
        pass
    # Open documentation: https://docs.python.org/3/library/functions.html#open
    logfile_fd = open(logfile, 'w')
    # Atexit documenteation: https://docs.python.org/3/library/atexit.html
    atexit.register(close_logfile)

    # Coroutine stuff
    # Give me the loop brother
    brother = asyncio.get_event_loop()
    # Shout outs to the TA slides
    server = asyncio.start_server(client_handler, host = '127.0.0.1', port = port_num, loop = brother)
    proxy = brother.run_until_complete(server)
    try:
        brother.run_forever()
    except KeyboardInterrupt:
        print("PROXY: Keyboard Interrupt")
        pass
    proxy.close()
    brother.run_until_complete(proxy.wait_closed())
    brother.close()
    print ("PROXY: Successful finish")
    sys.exit(0) #Successful exit
    
if __name__ == "__main__":
    main()