import struct
import binascii

f = open( "/dev/input/event3", "rb" ); # Open the file in the read-binary mode
while 1:
	data = f.read(16)
	print binascii.hexlify(data)
	print struct.unpack('2IHHI',data)
  ###### PRINT FORMAL = ( Time Stamp_INT , 0 , Time Stamp_DEC , 0 , 
  ######   type , code ( key pressed ) , value (press/release) )
