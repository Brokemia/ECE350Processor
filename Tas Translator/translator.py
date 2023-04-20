import serial, struct

# Button mapping for the processor encoding
button_index = {
    "a": 0,
    "b": 1,
    "x": 2,
    "y": 3,
    "lb":4,
    "rb":5,
    "back":6,
    "start":7,
    "l3":8,
    "r3":9,
    "d_up":10,
    "d_down":11,
    "d_left":12,
    "d_right":13,
    "trigger_left":14,
    "trigger_right":15
}

# Buttom mapping for game in question
control_mapping = {
    "J": "a",
    "C": "b",
    "X": "x",
    "K": "y",
    "V": "lb",
    "": "rb",
    "": "back",
    "S": "start",
    "": "l3",
    "": "r3",
    "U": "d_up",
    "D": "d_down",
    "L": "d_left",
    "R": "d_right",
    "Z": "trigger_left",
    "G": "trigger_right"
}


cmds = []
with open("Tases/1A.tas") as f:
    for line in f:
        line = line.strip()
        elements = line.split(",")
        elements[0] = int(elements[0])
        print(elements)
        cmd = [0 for _ in range(16)]
        for button in elements[1:]:
            cmd[button_index[control_mapping[button]]] = 1
        for _ in range(elements[0]):
            cmds.append(cmd)
        
        print(cmd)

print(cmds)

ser = serial.Serial(port='COM18', baudrate=115200)  # open serial port
print(ser.name)         # check which port was really used
for line in cmds:
    concated_cmd = ''.join([str(x) for x in line])
    print(concated_cmd, struct.pack(">H", int(concated_cmd, 2)))
    ser.write(struct.pack(">H", int(concated_cmd, 2)))     # write a string
ser.close()             # close port