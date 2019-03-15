import sys
import os
import asyncio
import atexit
import json
import time
import aiohttp

import serverinfo
from clientinfo import Client

def already_recorded(client_id, loc, time_stamp):
    # Returns true if the client is already in client_list
    # Returns false otherwise and adds the client
    if (client_id in client_list):
        if (client_list[client_id].loc == loc and client_list[client_id].clock == time_stamp):
            return True
    client_list[client_id] = Client(client_id, loc, time_stamp)
    return False

async def fludd(original_server, client_name, delta_time):
    say = ("AT {server} {time_dif} {client} {loc} {time_stamp}\n").format(server = name, time_dif = delta_time, client = client_name, loc = client_list[client_name].loc, time_stamp = client_list[client_name].clock)
    for connecting_server in serverinfo.server_bonds[name]:
        if (original_server != connecting_server):
            try:
                reader, writer = await asyncio.open_connection('127.0.0.1', serverinfo.server_portnums[connecting_server], loop = brother)
                await to_writer(writer, say)
                logfile_fd.write("To: " + connecting_server + say + '\n')
                logfile_fd.flush()
            except:
                print("Cannot connect to: " + connecting_server)
                logfile_fd.write("Cannot connect to: " + connecting_server + '\n')
                logfile_fd.flush()
    return

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
    
#Taken from the aiohttp documentation: https://aiohttp.readthedocs.io/en/stable/
async def fetch(session, url):
    async with session.get(url) as response:
        return await response.json()

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
    holdme = holdme.decode()
    logfile_fd.write('Received: ' + str(holdme) + '\n') #TODO: Format this, thanks
    logfile_fd.flush() # Fixes writing to file out of order bug

    command = format(holdme)
    if (not command):
        await to_writer(writer, '?' + str(holdme) + '\n')
        logfile_fd.write('?' + str(holdme))
        logfile_fd.flush()
        return
    if (command[0] == "IAMAT"):
        print("PROXY: IAMAT command received")
        # Check valid arguments for command
        if (len(command) != 4):
            print("Please use the IAMAT command in the following manner: IAMAT <client-id> <ISO6709-location> <POSIX-time>", file = sys.stderr)
            logfile_fd.write('?' + str(holdme) + '\n')
            logfile_fd.flush()
            sys.exit(1)
        new_client = Client(command[1], command[2], command[3])
        client_list[command[1]] = new_client
        time_change = received_time - float(command[3])
        if (time_change >= 0):
            pos = "+"
        else:
            pos = "-"
        say = "AT " + name + " " + pos + str(time_change) + " " + new_client.id + " " + new_client.loc + " " + new_client.clock + '\n'
        await to_writer(writer, say)
        logfile_fd.write(say)
        logfile_fd.flush()
        await fludd(name, new_client.id, time_change)
    elif (command[0] == "WHATSAT"):
        if (len(command) != 4):
            print("Please use the WHATSAT command in the following manner: WHATSAT <client-id> <radius> <result-count>", file = sys.stderr)
            logfile_fd.write('?' + str(holdme) + '\n')
            logfile_fd.flush()
            sys.exit(1)
        if (command[1] not in client_list):
            print("Please use the WHATSAT command with a recorded client.", file = sys.stderr)
            logfile_fd.write('?' + str(holdme) + '\n')
            logfile_fd.flush()
            sys.exit(1)
        if ((int(command[2]) > 50) or (int(command[2]) < 0)):
            print("Please use the WHATSAT command with a radius between 0 and 50.", file = sys.stderr)
            logfile_fd.write('?' + str(holdme) + '\n')
            logfile_fd.flush()
            sys.exit(1)
        if ((int(command[3]) > 20) or (int(command[3]) < 0)):
            print("Please use the WHATSAT command with a result-coubt between 0 and 20.", file = sys.stderr)
            logfile_fd.write('?' + str(holdme) + '\n')
            logfile_fd.flush()
            sys.exit(1)
        print("PROXY: WHATSAT command received")
        #Google Places Documentation: https://developers.google.com/places/web-service/search#PlaceSearchRequests
        request = ("{url}location={lat},{lon}&radius={rad}&key={key}").format(url = serverinfo.url, lat = client_list[command[1]].lat, lon = client_list[command[1]].lon, rad = (int(command[2]) * 1000), key = serverinfo.api_key)
        async with aiohttp.ClientSession() as client_session:
            result = await fetch(client_session, request)
            result['results'] = result['results'][:int(command[3])]
        time_difference = time.time() - float(client_list[command[1]].clock)
        json_request = ("AT {server} {time_dif} {client} {location} {timestamp}\n{dump}\n\n").format(server = name, time_dif = time_difference, client = command[1], location = client_list[command[1]].loc, timestamp = client_list[command[1]].clock, dump = (json.dumps(result, indent = 3)).rstrip())
        # JSON Documentation: https://docs.python.org/2/library/json.html
        await to_writer(writer, json_request)
        logfile_fd.write(json_request)
        logfile_fd.flush()
    elif (command[0] == "AT"):
        if (len(command) != 6):
            print("Please use the AT command in the following format: AT <server-name> <time-difference> <cliend-id> <ISO6709-locaiton> <POSIX-time>", file = sys.stderr)
            logfile_fd.write('?' + str(holdme) + '\n')
            logfile_fd.flush()
            sys.exit(1)
        if (already_recorded(command[3], command[4], command[5])): # Already received this
            return
        else:
            time_change = received_time - float(command[5])
            if (time_change >= 0):
                pos = "+"
            else:
                pos = "-"
            await fludd(command[1], command[3], pos + str(time_change))
            return
    else:
        await to_writer(writer, '?' + str(holdme) + '\n')
        logfile_fd.write('?' + str(holdme) + '\n')
        logfile_fd.flush()
        sys.exit(1)
    return

def main():
    # Global variables so that I don't have to pass them everytime mb
    global name
    global logfile
    global logfile_fd
    global client_list
    global brother
    client_list = {}
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
        print("Keyboard Interrupt")
        pass
    proxy.close()
    brother.run_until_complete(proxy.wait_closed())
    brother.close()
    print ("Successful finish")
    sys.exit(0) #Successful exit
    
if __name__ == "__main__":
    main()