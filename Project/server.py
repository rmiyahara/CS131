import sys
import os
import asyncio
import atexit

import serverinfo
def checkservername(name): #Exits if server is not valid
    if name not in serverinfo.server_boiz:
        print("Please use a valid server name: " + str(serverinfo.server_boiz), file = sys.stderr)
        sys.exit(1)
    return

def launch_server(): # Starts server using asyncio
    #https://docs.python.org/3/library/asyncio-stream.html#asyncio.start_server
    return

def close_logfile(): # Closes the logfile file descriptor
    logfile_fd.close()
    print("PROXY: File closed")
    return

def main():
    # Global variables so that I don't have to pass them everytime
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
    
    # Open log file
    logfile = name + ".txt"
    # Try documentation: https://docs.python.org/3/tutorial/errors.html
    # Remove
    try:
        os.remove(logfile)
    except FileNotFoundError:
        pass
    # Open documentation: https://docs.python.org/3/library/functions.html#open
    logfile_fd = open(logfile, 'w')
    # Atexit documenteation: https://docs.python.org/3/library/atexit.html
    atexit.register(close_logfile)
    print ("PROXY: Successful finish")
    return 0 #Successful exit
    
if __name__ == "__main__":
    main()