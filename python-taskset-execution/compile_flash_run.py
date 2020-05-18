import os
from threading import Thread
from subprocess import Popen, PIPE
import signal


# compile Ravenscar and flash the program into the board
def compile_and_flash_into_board (EDF0_FPS1):
    # use your location
    if (EDF0_FPS1 == 0):
        os.system("gprbuild --target=arm-eabi -d -P/home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/unit01.gpr /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/src/unit01.adb -largs -Wl,-Map=map.txt")
        os.system("arm-eabi-objdump /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/unit01 -h")
        os.system("arm-eabi-objcopy -O binary /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/unit01 /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/unit01.bin")
        os.system("st-flash write /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/unit01.bin 0x08000000")
    else:
        os.system("gprbuild --target=arm-eabi -d -P/home/aquox/Scrivania/comparison-system-FPS-EDF/fps-ravenscar-arm/unit01.gpr /home/aquox/Scrivania/comparison-system-FPS-EDF/fps-ravenscar-arm/src/unit01.adb -largs -Wl,-Map=map.txt")
        os.system("arm-eabi-objdump /home/aquox/Scrivania/comparison-system-FPS-EDF/fps-ravenscar-arm/unit01 -h")
        os.system("arm-eabi-objcopy -O binary /home/aquox/Scrivania/comparison-system-FPS-EDF/fps-ravenscar-arm/unit01 /home/aquox/Scrivania/comparison-system-FPS-EDF/fps-ravenscar-arm/unit01.bin")
        os.system("st-flash write /home/aquox/Scrivania/comparison-system-FPS-EDF/fps-ravenscar-arm/unit01.bin 0x08000000")


# We need a separate Thread for call the st-util tool
class st_util_thread (Thread):
    def __init__(self):
        Thread.__init__(self)
        self.st_util = Popen (["st-util"], stdin= PIPE, stdout= PIPE)
    def run(self):
        while True and self.st_util.poll() == None:
            self.st_util.stdout.readline()
    def stop(self):
        self.st_util.send_signal(signal.SIGINT)


# run the program with the debugger and read the data from the data struct of important data
def debug_and_read_data (taskset, EDF0_FPS1):
    st_util = st_util_thread()
    st_util.start()
    data = []
    # use your location
    if (EDF0_FPS1 == 0):
        command = ["arm-eabi-gdb /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/unit01"]
    else:
        command = ["arm-eabi-gdb /home/aquox/Scrivania/comparison-system-FPS-EDF/fps-ravenscar-arm/unit01"]
    # run the program with debugger
    debugger = Popen (command, shell=True, stdout=PIPE, stdin= PIPE)
    # read the data
    while True and debugger.poll() == None:
        line = debugger.stdout.readline()
        print(line)
        if "Reading symbols" in line.decode():
            debugger.stdin.write("tar extended-remote :4242\n".encode())
            debugger.stdin.flush()
        if "_start_rom" in line.decode():
            debugger.stdin.write("monitor reset halt\n".encode())
            debugger.stdin.flush()
            debugger.stdin.write("del br\n".encode())
            debugger.stdin.flush()
            if (EDF0_FPS1 == 0):
                debugger.stdin.write("break s-bbthqu.adb:125\n".encode())   # EDF
            else:
                debugger.stdin.write("break s-bbthqu.adb:113\n".encode())     # FPS
            debugger.stdin.flush()
            debugger.stdin.write("c\n".encode())
            debugger.stdin.flush()
        if "System.IO.Put" in line.decode():
            for i in range (len(taskset)):
                debugger.stdin.write(("p Log_Table ("+str(i+1)+").DM\n").encode())
                debugger.stdin.flush()
                DM_Line = debugger.stdout.readline().decode().split(" ")

                debugger.stdin.write(("p Log_Table (" + str(i + 1) + ").Runs\n").encode())
                debugger.stdin.flush()
                Execution_Line = debugger.stdout.readline().decode().split(" ")

                debugger.stdin.write(("p Log_Table (" + str(i + 1) + ").Preemption\n").encode())
                debugger.stdin.flush()
                Preemption_Line = debugger.stdout.readline().decode().split(" ")

                debugger.stdin.write(("p Log_Table (" + str(i + 1) + ").Min_Response_Jitter\n").encode())
                debugger.stdin.flush()
                Min_Work_Jitter_Line = debugger.stdout.readline().decode().split(" ")

                debugger.stdin.write(("p Log_Table (" + str(i + 1) + ").Max_Response_Jitter\n").encode())
                debugger.stdin.flush()
                Max_Work_Jitter_Line = debugger.stdout.readline().decode().split(" ")

                debugger.stdin.write(("p Log_Table (" + str(i + 1) + ").Min_Release_Jitter\n").encode())
                debugger.stdin.flush()
                Min_Release_Jitter_Line = debugger.stdout.readline().decode().split(" ")

                debugger.stdin.write(("p Log_Table (" + str(i + 1) + ").Max_Release_Jitter\n").encode())
                debugger.stdin.flush()
                Max_Release_Jitter_Line = debugger.stdout.readline().decode().split(" ")

                debugger.stdin.write(("p Log_Table (" + str(i + 1) + ").Average_Response_Jitter\n").encode())
                debugger.stdin.flush()
                Avarage_Work_Jitter_Line = debugger.stdout.readline().decode().split(" ")

                data.append([DM_Line[3].rstrip(), Execution_Line[3].rstrip(), Preemption_Line[3].rstrip(), Min_Work_Jitter_Line[3].rstrip(), Max_Work_Jitter_Line[3].rstrip(), Min_Release_Jitter_Line[3].rstrip(), Max_Release_Jitter_Line[3].rstrip(), Avarage_Work_Jitter_Line[3].rstrip()])
            debugger.stdin.write(("quit\n").encode())
            debugger.stdin.flush()
            debugger.kill()
            st_util.stop()
            st_util.join(1)
    return data