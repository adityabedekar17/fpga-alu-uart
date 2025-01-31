import serial
import serial.threaded

class Echo(serial.threaded.protocol):
    def data_received(self,data):
        print(data)
def echo(ser,message):
     header = [0xec, 0x00, 0x06,0x00]
     Msgbytes = bytearray(header)+ bytearray(message)
     ser.write(Msgbytes)

'''class PrintLines(LineReader):
    def connection_made(self, transport):
        super(PrintLines, self).connection_made(transport)
        sys.stdout.write('port opened\n')
        self.write_line('hello world')


    def handle_line(self, data):
        sys.stdout.write('line received: {}\n'.format(repr(data)))

    def connection_lost(self, exc):
        if exc:
            traceback.print_exc(exc)
        sys.stdout.write('port closed\n')'''

ser = serial.Serial('/dev/ttyACM0', baudrate=115200, timeout=1)
rt = serial.threaded.ReaderThread(ser,echo)
    
