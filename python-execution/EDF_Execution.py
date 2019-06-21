import csv
import os
import subprocess
from threading import Thread
from subprocess import Popen, PIPE
from datetime import datetime
import time
import signal

####################
## Import Taskset ##     # Da mettere su file principale
####################

def import_taskset(taskset, i):
    utilization = 0
    L = 0
    first_deadline_miss = 0
    schedulable = -1
    hyperperiod = 0

    with open('../workspace/tasksets.csv') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=';')
        row_number = 0
        for row in csv_reader:
            if row_number == i:
                utilization = row[0]
                L = row[1]
                first_deadline_miss = row[2]
                schedulable = row[3]
                hyperperiod = row[4]
                for task in range (len(row)-6):
                    string_task = row[task+5].split(",")
                    task = [string_task[0],
                            string_task[1],
                            string_task[2],
                            string_task[3],
                            string_task[4]]
                    taskset.append (task)
            row_number = row_number + 1
    return taskset, utilization, L, first_deadline_miss, schedulable, hyperperiod

##############################
## Make ADB file to compile ##  # Da mettere su file principale?
##############################

def make_adb_file (taskset, hyperPeriod):
    file_adb = open("../fps-ravenscar-arm/src/cyclic_tasks.adb", "w")
    file_adb.write("with Ada.Real_Time; use Ada.Real_Time;\n")
    file_adb.write("with System_Time;\n")
    file_adb.write("with System.Task_Primitives.Operations;\n")
    file_adb.write("with System.BB.Time;\n")
    file_adb.write("with System.BB.Threads;\n")
    file_adb.write("with System.BB.Threads.Queues;\n")
    file_adb.write("with Print_Task;\n")
    file_adb.write("\n")
    file_adb.write("package body Cyclic_Tasks is\n")
    file_adb.write("\n")
    file_adb.write("   task body Cyclic is\n")
    file_adb.write("      Task_Static_Offset : constant Time_Span :=\n")
    file_adb.write("               Ada.Real_Time.Microseconds (500000);\n")
    file_adb.write("\n")
    file_adb.write("      Next_Period : Ada.Real_Time.Time := System_Time.System_Start_Time\n")
    file_adb.write("            + System_Time.Task_Activation_Delay + Task_Static_Offset;\n")
    file_adb.write("\n")
    file_adb.write("      Period : constant Ada.Real_Time.Time_Span :=\n")
    file_adb.write("               Ada.Real_Time.Microseconds (Cycle_Time);\n")
    file_adb.write("\n")
    file_adb.write("      procedure Gauss (Times : Integer);\n")
    file_adb.write("      procedure Gauss (Times : Integer) is\n")
    file_adb.write("         Num : Integer := 0;\n")
    file_adb.write("      begin\n")
    file_adb.write("         for I in 1 .. Times loop\n")
    file_adb.write("            Num := Num + I;\n")
    file_adb.write("         end loop;\n")
    file_adb.write("      end Gauss;\n")
    file_adb.write("      Temp : Integer;\n")
    file_adb.write("\n")
    file_adb.write("   begin\n")
    file_adb.write("      System.Task_Primitives.Operations.Set_Relative_Deadline\n")
    file_adb.write("         (System.Task_Primitives.Operations.Self,\n")
    file_adb.write("          System.BB.Time.Microseconds (Dead));\n")
    file_adb.write("      System.BB.Threads.Set_Fake_Number_ID (T_Num);\n")
    file_adb.write("      System.BB.Threads.Queues.Initialize_Task_Table (T_Num);\n")
    file_adb.write("\n")
    file_adb.write("      loop\n")
    file_adb.write("         delay until Next_Period;\n")
    file_adb.write("\n")
    file_adb.write("         Temp := Gauss_Num;\n")
    file_adb.write("         Gauss (Temp);\n")
    file_adb.write("\n")
    file_adb.write("         Next_Period := Next_Period + Period;\n")
    file_adb.write("      end loop;\n")
    file_adb.write("   end Cyclic;\n")
    file_adb.write("\n")
    file_adb.write("   procedure Init is\n")
    file_adb.write("   begin\n")
    file_adb.write("      System.Task_Primitives.Operations.Set_Relative_Deadline\n")
    file_adb.write("        (System.Task_Primitives.Operations.Self,\n")
    file_adb.write("          System.BB.Time.Milliseconds (Integer'Last));\n")
    file_adb.write("      loop\n")
    file_adb.write("         null;\n")
    file_adb.write("      end loop;\n")
    file_adb.write("   end Init;\n")
    file_adb.write("\n")
    file_adb.write("   P1 : Print_Task.Print (240, -" + str(1)+ ", " + str(int(hyperPeriod/1000)) + "); -- period in milliseconds\n")
    ##  file_adb.write("   P1 : Print_Task.Print (240, -" + str(1) + ", " + str(5000) + "); -- period in milliseconds\n")
    for task in range (len(taskset)):
        work = int((float(taskset[task][4])-1.62)*180/17)
        #### DA METTERE APPOSTO PER ID
        file_adb.write("   C"+str(task+1)+" : Cyclic ("+str(len(taskset)-task)+", "
                                                    +str(taskset[task][1])+", "
                                                    +str(taskset[task][2])+", "
                                                    +str(task+1)+", "
                                                    +str(work)+");\n")
    file_adb.write ("end Cyclic_Tasks;")

#############################################
##  Compile and flash ravenscar into board ##
#############################################

def compile_and_flash_into_board ():
    #os.system("gprbuild --target=arm-eabi -d -P/home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01.gpr /home/aquox/Scrivania/Arm/edf-ravenscar-arm/src/unit01.adb -largs -Wl,-Map=map.txt")
    #os.system("arm-eabi-objdump /home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01 -h")
    #os.system("arm-eabi-objcopy -O binary /home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01 /home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01.bin")
    #os.system("st-flash write /home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01.bin 0x08000000")

    os.system(
        "gprbuild --target=arm-eabi -d -P/home/aquox/Scrivania/Arm/fps-ravenscar-arm/unit01.gpr /home/aquox/Scrivania/Arm/fps-ravenscar-arm/src/unit01.adb -largs -Wl,-Map=map.txt")
    os.system("arm-eabi-objdump /home/aquox/Scrivania/Arm/fps-ravenscar-arm/unit01 -h")
    os.system(
        "arm-eabi-objcopy -O binary /home/aquox/Scrivania/Arm/fps-ravenscar-arm/unit01 /home/aquox/Scrivania/Arm/fps-ravenscar-arm/unit01.bin")
    os.system("st-flash write /home/aquox/Scrivania/Arm/fps-ravenscar-arm/unit01.bin 0x08000000")


##################################################
##  Debug program and save results into a file  ##
##################################################

##  Separate Thread for call the st-util tool
class st_util_thread (Thread):
    def __init__(self):
        Thread.__init__(self)
        self.st_util = Popen (["st-util"], stdin= PIPE, stdout= PIPE)
    def run(self):
        while True and self.st_util.poll() == None:
            print(self.st_util.stdout.readline())
    def stop(self):
        self.st_util.send_signal(signal.SIGINT)

def debug_and_save_data (taskset, hyperperiod):
    st_util = st_util_thread()
    st_util.start()
    command =["arm-eabi-gdb /home/aquox/Scrivania/Arm/fps-ravenscar-arm/unit01"]
    debugger = Popen (command, shell=True, stdout=PIPE, stdin= PIPE)
    while True and debugger.poll() == None:
        line = debugger.stdout.readline()
        print(line)
        if "Reading symbols" in line.decode():
            debugger.stdin.write("tar extended-remote :4242\n".encode())
            debugger.stdin.flush()
        if "_start_rom" in line.decode():
            debugger.stdin.write("monitor reset halt\n".encode())
            debugger.stdin.flush()
            # debugger.stdin.write("break s-bbthqu.adb:134\n".encode())   # EDF
            debugger.stdin.write("break s-bbthqu.adb:119\n".encode())     # FPS
            debugger.stdin.flush()
            debugger.stdin.write("c\n".encode())
            debugger.stdin.flush()
        if "System.IO.Put" in line.decode():
            now = datetime.now()
            with open('../workspace2/taskset'+str(now)+'.csv', mode='w') as csv_to_write:
                csv_writer = csv.writer(csv_to_write, delimiter=';')
                csv_writer.writerow(
                    ['Priority', 'Period', 'Deadline', 'ID', 'Work', 'Deadline Miss', 'Executions', 'Preemptions'])
                for i in range (len(taskset)):
                    debugger.stdin.write(("p Task_Table ("+str(i+1)+").DM\n").encode())
                    debugger.stdin.flush()
                    DM_Line = debugger.stdout.readline().decode().split(" ")
                    print("DML " + str(DM_Line))
                    debugger.stdin.write(("p Task_Table (" + str(i + 1) + ").Execution\n").encode())
                    debugger.stdin.flush()
                    Execution_Line = debugger.stdout.readline().decode().split(" ")
                    print("EL "+ str(Execution_Line))
                    debugger.stdin.write(("p Task_Table (" + str(i + 1) + ").Preemption\n").encode())
                    debugger.stdin.flush()
                    Preemption_Line = debugger.stdout.readline().decode().split(" ")
                    print("Pr_L " + str(Preemption_Line))
                    debugger.stdin.write(("c\n").encode())
                    debugger.stdin.flush()
                    debugger.stdout.readline()  # 4 per EDF
                    debugger.stdout.readline()  # 6 per FPS
                    debugger.stdout.readline()
                    debugger.stdout.readline()
                    debugger.stdout.readline()
                    debugger.stdout.readline()

                    csv_writer.writerow([taskset[i][0], taskset[i][1], taskset[i][2], taskset[i][3], taskset[i][4],
                                         DM_Line[3].rstrip(), Execution_Line[3].rstrip(), Preemption_Line[3].rstrip()])
                csv_writer.writerow(['hyperperiod',hyperperiod])
                debugger.stdin.write(("quit\n").encode())
                debugger.stdin.flush()
                debugger.kill()
                st_util.stop()
                st_util.join(1)


##########
## Main ##
##########


for i in range (1):

    taskset = []
    taskset, utilization, L, first_deadline_miss, schedulable, hyperperiod = import_taskset(taskset, i)

    print (utilization)
    print(L)
    print(first_deadline_miss)
    print(schedulable)
    print(hyperperiod)

    #make_adb_file(taskset, 952560000)



    #compile_and_flash_into_board()
    #debug_and_save_data(taskset, 952560000)




# utilization = 0
    # #utilization2 = 0
    # for task in range(len(taskset)):
    #     work = int((float(taskset[task][4]) - 2) * 180 / 17)
    #     utilization = utilization + (work*17/180) / float(taskset[task][1])
    #     utilization = utilization + 18/float(taskset[task][1])
    #     #utilization2 = utilization2 + float(taskset[task][4])/float(taskset[task][1])
    # #print(utilization)



