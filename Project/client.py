import sys
import asyncio

async def confirm_connection(loop, say):
    reader, writer = await asyncio.open_connection(host = '127.0.0.1', port = 12165, loop = loop)
    writer.write(say.encode())
    await writer.drain()

    command = await reader.readline()
    command = command.decode()
    print(command)
    writer.close()
    return

def main():
    brother = asyncio.get_event_loop()
    brother.run_until_complete(confirm_connection(brother, "IAMAT Isaac +34.0676828-118.4554165 1552560377.0\n"))
    brother.close()
    print("PROXY: Connection made")
    print("PROXY: Client finished")
    sys.exit(0)
    

if __name__ == "__main__":
    main()