import csv
import os
from threading import Thread
from subprocess import Popen, PIPE
from datetime import datetime
import signal


####################
## Import Taskset ##
####################

def import_taskset(taskset, i, name):

    with open('../workspace/' + str(name)) as csv_file:
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
                return taskset, utilization, L, first_deadline_miss, schedulable, hyperperiod
            row_number = row_number + 1

##############################
## Make ADB file to compile ##  # Da mettere su file principale?
##############################

def make_adb_file (taskset, hyperPeriod):
    for i in range (2):
        if i == 0 :
            file_adb = open("../edf-ravenscar-arm/src/cyclic_tasks.adb", "w")
        else:
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
        if i == 1:
            file_adb.write("      Starting_Time_Ada_Real_Time :\n")
            file_adb.write("      constant Ada.Real_Time.Time_Span\n")
            file_adb.write("        := Next_Period - Ada.Real_Time.Time_First;\n")
            file_adb.write("      Starting_Time_BB_Time : System.BB.Time.Time_Span;\n")
        file_adb.write("\n")
        file_adb.write("   begin\n")
        if i == 1:
            file_adb.write("      Starting_Time_BB_Time := System.BB.Time.To_Time_Span\n")
            file_adb.write("        (Ada.Real_Time.To_Duration (Starting_Time_Ada_Real_Time));\n")
            file_adb.write("      System.Task_Primitives.Operations.Set_Period\n")
            file_adb.write("         (System.Task_Primitives.Operations.Self,\n")
            file_adb.write("         System.BB.Time.Microseconds (Cycle_Time));\n")
            file_adb.write("      System.Task_Primitives.Operations.Set_Starting_Time\n")
            file_adb.write("        (System.Task_Primitives.Operations.Self,\n")
            file_adb.write("          Starting_Time_BB_Time);\n")
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
        file_adb.write("   P1 : Print_Task.Print (240, -" + str(1)+ ", " + str(int(float(hyperPeriod)/1000)) + "); -- period in milliseconds\n")
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
        file_adb.close()
    # os.system("cp ../edf-ravenscar-arm/src/cyclic_tasks.adb ../fps-ravenscar-arm/src/cyclic_tasks.adb")


#############################################
##  Compile and flash ravenscar into board ##
#############################################

def compile_and_flash_into_board (EDF0_FPS1):

    if (EDF0_FPS1 == 0):
        os.system("gprbuild --target=arm-eabi -d -P/home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01.gpr /home/aquox/Scrivania/Arm/edf-ravenscar-arm/src/unit01.adb -largs -Wl,-Map=map.txt")
        os.system("arm-eabi-objdump /home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01 -h")
        os.system("arm-eabi-objcopy -O binary /home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01 /home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01.bin")
        os.system("st-flash write /home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01.bin 0x08000000")
    else:
        os.system("gprbuild --target=arm-eabi -d -P/home/aquox/Scrivania/Arm/fps-ravenscar-arm/unit01.gpr /home/aquox/Scrivania/Arm/fps-ravenscar-arm/src/unit01.adb -largs -Wl,-Map=map.txt")
        os.system("arm-eabi-objdump /home/aquox/Scrivania/Arm/fps-ravenscar-arm/unit01 -h")
        os.system("arm-eabi-objcopy -O binary /home/aquox/Scrivania/Arm/fps-ravenscar-arm/unit01 /home/aquox/Scrivania/Arm/fps-ravenscar-arm/unit01.bin")
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
            self.st_util.stdout.readline()
            #print(self.st_util.stdout.readline())
    def stop(self):
        self.st_util.send_signal(signal.SIGINT)

def debug_and_read_data (taskset, hyperperiod, EDF0_FPS1):
    st_util = st_util_thread()
    st_util.start()
    data = []
    if (EDF0_FPS1 == 0):
        command = ["arm-eabi-gdb /home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01"]
    else:
        command = ["arm-eabi-gdb /home/aquox/Scrivania/Arm/fps-ravenscar-arm/unit01"]
    debugger = Popen (command, shell=True, stdout=PIPE, stdin= PIPE)
    while True and debugger.poll() == None:
        line = debugger.stdout.readline()
        #print(line)
        if "Reading symbols" in line.decode():
            debugger.stdin.write("tar extended-remote :4242\n".encode())
            debugger.stdin.flush()
        if "_start_rom" in line.decode():
            debugger.stdin.write("monitor reset halt\n".encode())
            debugger.stdin.flush()
            if (EDF0_FPS1 == 0):
                debugger.stdin.write("break s-bbthqu.adb:134\n".encode())   # EDF
            else:
                debugger.stdin.write("break s-bbthqu.adb:119\n".encode())     # FPS
            debugger.stdin.flush()
            debugger.stdin.write("c\n".encode())
            debugger.stdin.flush()
        if "System.IO.Put" in line.decode():
            for i in range (len(taskset)):
                debugger.stdin.write(("p Task_Table ("+str(i+1)+").DM\n").encode())
                debugger.stdin.flush()
                DM_Line = debugger.stdout.readline().decode().split(" ")
                #print("DML " + str(DM_Line))
                debugger.stdin.write(("p Task_Table (" + str(i + 1) + ").Execution\n").encode())
                debugger.stdin.flush()
                Execution_Line = debugger.stdout.readline().decode().split(" ")
                #print("EL "+ str(Execution_Line))
                debugger.stdin.write(("p Task_Table (" + str(i + 1) + ").Preemption\n").encode())
                debugger.stdin.flush()
                Preemption_Line = debugger.stdout.readline().decode().split(" ")
                #print("Pr_L " + str(Preemption_Line))
                data.append([DM_Line[3].rstrip(), Execution_Line[3].rstrip(), Preemption_Line[3].rstrip()])
            debugger.stdin.write(("quit\n").encode())
            debugger.stdin.flush()
            debugger.kill()
            st_util.stop()
            st_util.join(1)
    return data

def save_data (taskset, EDF_data, FPS_data, name, unique_name, hyperperiod):

    now = datetime.now()
    with open('../workspace2/'+str(name)+'_'+str(unique_name)+'.csv', mode='w') as csv_to_write:
        csv_writer = csv.writer(csv_to_write, delimiter=';')
        csv_writer.writerow(
            ['ID', 'Priority', 'Period', 'Deadline', 'WCET', 'FPS Deadline Miss', 'FPS Executions', 'FPS Preemptions', 'Less', 'EDF Deadline Miss', 'EDF Executions', 'EDF Preemptions', 'Utilization by work'])
        sum_FPS_preemptions = 0
        sum_EDF_preemptions = 0
        sum_utilization = 0
        for i in range(len(taskset)):
            sum_FPS_preemptions = sum_FPS_preemptions + int(FPS_data[i][2])
            sum_EDF_preemptions = sum_EDF_preemptions + int(EDF_data[i][2])
            sum_utilization = sum_utilization + float(taskset[i][4]) / float(taskset[i][1])
            csv_writer.writerow([taskset[i][3], taskset[i][0], taskset[i][1], taskset[i][2], taskset[i][4],
                                 str(int(FPS_data[i][0])), str(int(FPS_data[i][1])), str(int(FPS_data[i][2])),
                                 str(int(FPS_data[i][2])-int(EDF_data[i][2])), str(EDF_data[i][0]),
                                 str(EDF_data[i][1]),str(EDF_data[i][2]),
                                 str(float(taskset[i][4])/float(taskset[i][1]))])
        csv_writer.writerow(['', '', hyperperiod, '', '', '', '', str(sum_FPS_preemptions), '', '', '', str(sum_EDF_preemptions), str(sum_utilization)])
        csv_writer.writerow(
            ['', '', '', '', '', '', '', str(float((sum_FPS_preemptions - sum_EDF_preemptions)/sum_FPS_preemptions)), '', '', '', '', ''])
################
## TEST TYPES ##
################

def buttazzo_experiments_preemptions ():
    for i in range(7001,7002):
        taskset = []
        taskset, utilization, L, first_deadline_miss, schedulable, hyperperiod = import_taskset(taskset, i, "buttazzo_preemptions.csv")
        print(taskset)
        make_adb_file(taskset, hyperperiod)
        EDF_data = []
        FPS_data = []
        for j in range(2):
            compile_and_flash_into_board(j)
            if (j==0):
                EDF_data = debug_and_read_data(taskset, hyperperiod, j)
            else:
                FPS_data = debug_and_read_data(taskset, hyperperiod, j)
        if i<9000:
            save_data(taskset, EDF_data, FPS_data, "Buttazzo-First-Preemptions", i+1, hyperperiod)
        else:
            save_data(taskset, EDF_data, FPS_data, "Buttazzo-Second-Preemptions", i+1-9000, hyperperiod)
##########
## Main ##
##########

buttazzo_experiments_preemptions()


# for i in range (1):
#
#     taskset = []
#     taskset, utilization, L, first_deadline_miss, schedulable, hyperperiod = import_taskset(taskset, i)
#
#     print (utilization)
#     print(L)
#     print(first_deadline_miss)
#     print(schedulable)
#     print(hyperperiod)
#
#     make_adb_file(taskset, 952560000)
#
#
#
#     compile_and_flash_into_board()
#     debug_and_save_data(taskset, 952560000)




# utilization = 0
    # #utilization2 = 0
    # for task in range(len(taskset)):
    #     work = int((float(taskset[task][4]) - 2) * 180 / 17)
    #     utilization = utilization + (work*17/180) / float(taskset[task][1])
    #     utilization = utilization + 18/float(taskset[task][1])
    #     #utilization2 = utilization2 + float(taskset[task][4])/float(taskset[task][1])
    # #print(utilization)



