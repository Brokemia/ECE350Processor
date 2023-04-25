import sys
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
# DPAD DOWN IS BROKEN :(
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


def enumerate_cmds():
    cmds = []
    with open("Tases/1A.tas") as f:
        for line in f:
            line = line.strip()
            elements = line.split(",")
            elements[0] = int(elements[0])
            cmd = [0 for _ in range(16)]
            for button in elements[1:]:
                cmd[button_index[control_mapping[button]]] = 1
            for _ in range(elements[0]):
                cmds.append(cmd)
            


    # ser = serial.Serial(port='COM18', baudrate=115200)  # open serial port
    # print(ser.name)         # check which port was really used
    # for line in cmds:
    #     concated_cmd = ''.join([str(x) for x in line])
    #     print(concated_cmd, struct.pack(">H", int(concated_cmd, 2)))
    #     ser.write(struct.pack(">H", int(concated_cmd, 2)))     # write a string
    # ser.close()             # close port

    with open("mem_files/1a.mem", "w") as f:
        test  = [''.join([str(x) for x in line]) for line in cmds]
        print(test)
        for line in cmds:
            f.write(''.join([str(x) for x in line]))
            f.write("\n")

def cmd_counts(name):
    cmds = []
    with open(f"Tases/{name}.tas") as f:
        for line in f:
            # Process Tasline
            line = line.strip()
            elements = line.split(",")
            elements[0] = int(elements[0])

            # Initialize binary and fill according to pressed buttons
            cmd = [0 for _ in range(16)]
            for button in elements[1:]:
                cmd[button_index[control_mapping[button]]] = 1
            
            # Add binary and number of frames to cmds
            cmds.append([cmd, elements[0]])

    with open(f"mem_files/{name}.mem", "w") as f:
        for line in cmds:
            # Line is [binary, frame count]
            f.write('{0:016b}'.format(line[1]))
            f.write(''.join([str(x) for x in line[0]]))
            f.write("\n")


cmd_counts(sys.argv[1])