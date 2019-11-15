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
                EDF_busy_period = row[1]
                FPS_busy_period = row[2]
                EDF_first_DM = row[3]
                EDF_schedulable = row[4]
                FPS_schedulable = row[5]
                hyperperiod = row[6]
                for task in range (len(row)-8):
                    string_task = row[task+7].split(",")
                    task = [string_task[0],
                            string_task[1],
                            string_task[2],
                            string_task[3],
                            string_task[4],
                            str((float(string_task[8])+float(string_task[9])))]
                    taskset.append (task)
                return taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM, EDF_schedulable, FPS_schedulable, hyperperiod
            row_number = row_number + 1

##############################
## Make ADB file to compile ##  # Da mettere su file principale?
##############################

def make_adb_file (taskset, hyperPeriod):
    for i in range (2):

        file_adb = open("../edf-ravenscar-arm/src/cyclic_tasks.adb", "w")

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
        file_adb.write("               Ada.Real_Time.Microseconds (Offset);\n")
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
        file_adb.write("      function Time_Conversion (Time_in  : Ada.Real_Time.Time)\n")
        file_adb.write("                                return System.BB.Time.Time_Span;\n")
        file_adb.write("      function Time_Conversion (Time_in  : Ada.Real_Time.Time)\n")
        file_adb.write("                                return System.BB.Time.Time_Span is\n")
        file_adb.write("         Time_in_to_Time_Span : Ada.Real_Time.Time_Span;\n")
        file_adb.write("         Time_out : System.BB.Time.Time_Span;\n")
        file_adb.write("      begin\n")
        file_adb.write("         Time_in_to_Time_Span := Time_in - Ada.Real_Time.Time_First;\n")
        file_adb.write("         Time_out := System.BB.Time.To_Time_Span\n")
        file_adb.write("           (Ada.Real_Time.To_Duration (Time_in_to_Time_Span));\n")
        file_adb.write("         return Time_out;\n")
        file_adb.write("      end Time_Conversion;\n")
        file_adb.write("\n")
        file_adb.write("      Temp : Integer;\n")
        file_adb.write("      Work_Jitter : Ada.Real_Time.Time;\n")
        file_adb.write("      Release_Jitter : Ada.Real_Time.Time;\n")
        file_adb.write("\n")
        file_adb.write("   begin\n")
        file_adb.write("      System.Task_Primitives.Operations.Set_Period\n")
        file_adb.write("         (System.Task_Primitives.Operations.Self,\n")
        file_adb.write("         System.BB.Time.Microseconds (Cycle_Time));\n")
        file_adb.write("      System.Task_Primitives.Operations.Set_Starting_Time\n")
        file_adb.write("        (System.Task_Primitives.Operations.Self,\n")
        file_adb.write("          Time_Conversion (Next_Period));\n")
        file_adb.write("      System.Task_Primitives.Operations.Set_Relative_Deadline\n")
        file_adb.write("         (System.Task_Primitives.Operations.Self,\n")
        file_adb.write("          System.BB.Time.Microseconds (Dead));\n")
        file_adb.write("      System.BB.Threads.Set_Fake_Number_ID (T_Num);\n")
        file_adb.write("      System.BB.Threads.Queues.Initialize_Task_Table (T_Num);\n")
        file_adb.write("\n")
        file_adb.write("      loop\n")
        file_adb.write("         delay until Next_Period;\n")
        file_adb.write("\n")
        file_adb.write("         Release_Jitter := Ada.Real_Time.Time_First +\n")
        file_adb.write("           (Ada.Real_Time.Clock - Next_Period);\n")
        file_adb.write("\n")
        file_adb.write("         Temp := Gauss_Num;\n")
        file_adb.write("         Gauss (Temp);\n")
        file_adb.write("\n")
        file_adb.write("         Work_Jitter := Ada.Real_Time.Time_First +\n")
        file_adb.write("           (Ada.Real_Time.Clock - (Release_Jitter\n")
        file_adb.write("            + (Next_Period - Ada.Real_Time.Time_First)));\n")
        file_adb.write("\n")
        file_adb.write("         Next_Period := Next_Period + Period;\n")
        file_adb.write("         System.Task_Primitives.Operations.Set_Jitters\n")
        file_adb.write("           (System.Task_Primitives.Operations.Self,\n")
        file_adb.write("           Time_Conversion (Work_Jitter), Time_Conversion (Release_Jitter));\n")
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
        file_adb.write("   P1 : Print_Task.Print (240, -" + str(1)+ ", " + str(int(float(hyperPeriod)/1000)) + ", 0); -- period in milliseconds\n")
        ##  file_adb.write("   P1 : Print_Task.Print (240, -" + str(1) + ", " + str(5000) + "); -- period in milliseconds\n")
        for task in range (len(taskset)):
            work = int((float(taskset[task][4])-1.62)*180/17)
            #### DA METTERE APPOSTO PER ID
            file_adb.write("   C"+str(task+1)+" : Cyclic ("+str(len(taskset)-task)+", "
                                                        +str(taskset[task][1])+", "
                                                        +str(taskset[task][2])+", "
                                                        +str(task+1)+", "
                                                        +str(work)+", 0);\n")
        file_adb.write ("end Cyclic_Tasks;")
        file_adb.close()
    os.system("cp ../edf-ravenscar-arm/src/cyclic_tasks.adb ../fps-ravenscar-arm/src/cyclic_tasks.adb")


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
                debugger.stdin.write("break s-bbthqu.adb:141\n".encode())   # EDF
            else:
                debugger.stdin.write("break s-bbthqu.adb:129\n".encode())     # FPS
            debugger.stdin.flush()
            debugger.stdin.write("c\n".encode())
            debugger.stdin.flush()
        if "System.IO.Put" in line.decode():
            for i in range (len(taskset)):
                debugger.stdin.write(("p Task_Table ("+str(i+1)+").DM\n").encode())
                debugger.stdin.flush()
                DM_Line = debugger.stdout.readline().decode().split(" ")

                debugger.stdin.write(("p Task_Table (" + str(i + 1) + ").Execution\n").encode())
                debugger.stdin.flush()
                Execution_Line = debugger.stdout.readline().decode().split(" ")

                debugger.stdin.write(("p Task_Table (" + str(i + 1) + ").Preemption\n").encode())
                debugger.stdin.flush()
                Preemption_Line = debugger.stdout.readline().decode().split(" ")

                debugger.stdin.write(("p Task_Table (" + str(i + 1) + ").Min_Work_Jitter\n").encode())
                debugger.stdin.flush()
                Min_Work_Jitter_Line = debugger.stdout.readline().decode().split(" ")

                debugger.stdin.write(("p Task_Table (" + str(i + 1) + ").Max_Work_Jitter\n").encode())
                debugger.stdin.flush()
                Max_Work_Jitter_Line = debugger.stdout.readline().decode().split(" ")

                debugger.stdin.write(("p Task_Table (" + str(i + 1) + ").Min_Release_Jitter\n").encode())
                debugger.stdin.flush()
                Min_Release_Jitter_Line = debugger.stdout.readline().decode().split(" ")

                debugger.stdin.write(("p Task_Table (" + str(i + 1) + ").Max_Release_Jitter\n").encode())
                debugger.stdin.flush()
                Max_Release_Jitter_Line = debugger.stdout.readline().decode().split(" ")

                debugger.stdin.write(("p Task_Table (" + str(i + 1) + ").Avarage_Work_Jitter\n").encode())
                debugger.stdin.flush()
                Avarage_Work_Jitter_Line = debugger.stdout.readline().decode().split(" ")

                data.append([DM_Line[3].rstrip(), Execution_Line[3].rstrip(), Preemption_Line[3].rstrip(), Min_Work_Jitter_Line[3].rstrip(), Max_Work_Jitter_Line[3].rstrip(), Min_Release_Jitter_Line[3].rstrip(), Max_Release_Jitter_Line[3].rstrip(), Avarage_Work_Jitter_Line[3].rstrip()])
            debugger.stdin.write(("quit\n").encode())
            debugger.stdin.flush()
            debugger.kill()
            st_util.stop()
            st_util.join(1)
    return data

def save_data (taskset, EDF_data, FPS_data, name, unique_name, hyperperiod):

    #now = datetime.now()
    with open('../workspace2/'+str(name)+'_'+str(unique_name)+'.csv', mode='w') as csv_to_write:
        csv_writer = csv.writer(csv_to_write, delimiter=';')
        csv_writer.writerow(
            ['ID', 'Priority', 'Period', 'Deadline', 'WCET', 'FPS Deadline Miss', 'FPS Executions', 'FPS Preemptions', 'Less', 'EDF Deadline Miss', 'EDF Executions', 'EDF Preemptions', 'Utilization by work', 'Utilization by calculable overheads', '', 'FPS Min Work Jitter', 'FPS Max Work Jitter', 'FPS Min Release Jitter', 'FPS Max Release Jitter', 'FPS Avarage Work Jitter', 'EDF Min Work Jitter', 'EDF Max Work Jitter', 'EDF Min Release Jitter', 'EDF Max Release Jitter', 'EDF Avarage Work Jitter'])
        sum_FPS_preemptions = 0
        sum_EDF_preemptions = 0
        sum_utilization = 0
        sum_utilization_by_overheads = 0
        for i in range(len(taskset)):
            sum_FPS_preemptions = sum_FPS_preemptions + int(FPS_data[i][2])
            sum_EDF_preemptions = sum_EDF_preemptions + int(EDF_data[i][2])
            sum_utilization = sum_utilization + float(taskset[i][4]) / float(taskset[i][1])
            sum_utilization_by_overheads = sum_utilization_by_overheads + float (taskset[i][5])
            csv_writer.writerow([taskset[i][3], taskset[i][0], taskset[i][1], taskset[i][2], taskset[i][4],
                                 str(int(FPS_data[i][0])), str(int(FPS_data[i][1])), str(int(FPS_data[i][2])),
                                 str(int(FPS_data[i][2])-int(EDF_data[i][2])),
                                 str(EDF_data[i][0]), str(EDF_data[i][1]),str(EDF_data[i][2]),
                                 str(float(taskset[i][4])/float(taskset[i][1])),
                                 str(taskset[i][5]), '',
                                 str(int(FPS_data[i][3])), str(int(FPS_data[i][4])), str(int(FPS_data[i][5])), str(int(FPS_data[i][6])), str(int(FPS_data[i][7])),
                                 str(int(EDF_data[i][3])), str(int(EDF_data[i][4])), str(int(EDF_data[i][5])), str(int(EDF_data[i][6])), str(int(EDF_data[i][7]))
                                 ])
        csv_writer.writerow(['', '', hyperperiod, '', '', '', '', str(sum_FPS_preemptions), '', '', '', str(sum_EDF_preemptions), str(sum_utilization), str(sum_utilization_by_overheads), str(sum_utilization+sum_utilization_by_overheads)])
        csv_writer.writerow(
            ['', '', '', '', '', '', '', str(float((sum_FPS_preemptions - sum_EDF_preemptions)/sum_FPS_preemptions)), '', '', '', '', ''])
################
## TEST TYPES ##
################

def buttazzo_experiments_preemptions ():
    for i in range(1,19001):
        taskset = []
        taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM, EDF_schedulable, FPS_schedulable, hyperperiod = import_taskset(taskset, i, "buttazzo_preemptions.csv")

        make_adb_file(taskset, hyperperiod)
        EDF_data = []
        FPS_data = []
        for j in range(2):
            compile_and_flash_into_board(j)
            if (j==0):
                EDF_data = debug_and_read_data(taskset, hyperperiod, j)
            else:
                FPS_data = debug_and_read_data(taskset, hyperperiod, j)
        if i<9001:
            save_data(taskset, EDF_data, FPS_data, "Buttazzo-First-Preemptions", i, hyperperiod)
        else:
            save_data(taskset, EDF_data, FPS_data, "Buttazzo-Second-Preemptions", i-9000, hyperperiod)

def buttazzo_experiments_preemptions_no_repetition ():
    for i in range(1,9501):
        taskset = []
        taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM, EDF_schedulable, FPS_schedulable, hyperperiod = import_taskset(taskset, i, "buttazzo_preemptions_no_repetition.csv")
        make_adb_file(taskset, hyperperiod)
        EDF_data = []
        FPS_data = []
        for j in range(2):
            compile_and_flash_into_board(j)
            if (j==0):
                EDF_data = debug_and_read_data(taskset, hyperperiod, j)
            else:
                FPS_data = debug_and_read_data(taskset, hyperperiod, j)
        if i<4501:
            save_data(taskset, EDF_data, FPS_data, "Buttazzo-First-Preemptions_no_repetition/Buttazzo-First-Preemptions_no_repetition", i, hyperperiod)
        else:
            save_data(taskset, EDF_data, FPS_data, "Buttazzo-Second-Preemptions_no_repetition/Buttazzo-Second-Preemptions_no_repetition", i-4500, hyperperiod)

def U_90_hyper_113400000():
    for i in range(1, 501):
        taskset = []
        taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM, EDF_schedulable, FPS_schedulable, hyperperiod = import_taskset(taskset, i, "U_90_hyper_113400000.csv")
        make_adb_file(taskset, hyperperiod)
        EDF_data = []
        FPS_data = []
        for j in range(2):
            compile_and_flash_into_board(j)
            if (j == 0):
                EDF_data = debug_and_read_data(taskset, hyperperiod, j)
            else:
                FPS_data = debug_and_read_data(taskset, hyperperiod, j)
        save_data(taskset, EDF_data, FPS_data, "U_90_hyper_113400000/U_90_hyper_113400000", i, hyperperiod)

def hyper_113400000_with_some_long():
    for l in range(4):
        for i in range(1, 501):
            taskset = []
            taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM, EDF_schedulable, FPS_schedulable, hyperperiod = import_taskset(taskset, i+(l*500), "hyper_113400000_10_200_with_some_long.csv")
            make_adb_file(taskset, hyperperiod)
            EDF_data = []
            FPS_data = []
            for j in range(2):
                compile_and_flash_into_board(j)
                if (j == 0):
                    EDF_data = debug_and_read_data(taskset, hyperperiod, j)
                else:
                    FPS_data = debug_and_read_data(taskset, hyperperiod, j)
            save_data(taskset, EDF_data, FPS_data, "U_"+ str(60+(l*10)) +"_hyper_113400000_with_some_long/U_"+ str(60+(l*10)) +"_hyper_113400000_with_some_long", i, hyperperiod)

def hyper_113400000_armonic_10_100():

    for i in range(1, 501):
        taskset = []
        taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM, EDF_schedulable, FPS_schedulable, hyperperiod = import_taskset(taskset, i, "hyper_113400000_0_2_armonic_10_100.csv")
        make_adb_file(taskset, hyperperiod)
        EDF_data = []
        FPS_data = []
        for j in range(2):
            compile_and_flash_into_board(j)
            if (j == 0):
                EDF_data = debug_and_read_data(taskset, hyperperiod, j)
            else:
                FPS_data = debug_and_read_data(taskset, hyperperiod, j)
        save_data(taskset, EDF_data, FPS_data, "U_"+ str(90) +"_hyper_113400000_0_2_armonic_10_100/U_"+ str(90) +"_hyper_113400000_0_2_armonic_10_100", i, hyperperiod)
    for i in range(1, 501):
        taskset = []
        taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM, EDF_schedulable, FPS_schedulable, hyperperiod = import_taskset(taskset, i, "hyper_113400000_3_6_armonic_10_100.csv")
        make_adb_file(taskset, hyperperiod)
        EDF_data = []
        FPS_data = []
        for j in range(2):
            compile_and_flash_into_board(j)
            if (j == 0):
                EDF_data = debug_and_read_data(taskset, hyperperiod, j)
            else:
                FPS_data = debug_and_read_data(taskset, hyperperiod, j)
        save_data(taskset, EDF_data, FPS_data, "U_"+ str(90) +"_hyper_113400000_3_6_armonic_10_100/U_"+ str(90) +"_hyper_113400000_3_6_armonic_10_100", i, hyperperiod)
    for i in range(1, 501):
        taskset = []
        taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM, EDF_schedulable, FPS_schedulable, hyperperiod = import_taskset(taskset, i, "hyper_113400000_7_20_armonic_10_100.csv")
        make_adb_file(taskset, hyperperiod)
        EDF_data = []
        FPS_data = []
        for j in range(2):
            compile_and_flash_into_board(j)
            if (j == 0):
                EDF_data = debug_and_read_data(taskset, hyperperiod, j)
            else:
                FPS_data = debug_and_read_data(taskset, hyperperiod, j)
        save_data(taskset, EDF_data, FPS_data, "U_"+ str(90) +"_hyper_113400000_7_20_armonic_10_100/U_"+ str(90) +"_hyper_113400000_7_20_armonic_10_100", i, hyperperiod)


def hyper_113400000_armonic_10_200():

    for i in range(1, 501):
        taskset = []
        taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM, EDF_schedulable, FPS_schedulable, hyperperiod = import_taskset(taskset, i, "hyper_113400000_3_6_armonic_10_200.csv")
        make_adb_file(taskset, hyperperiod)
        EDF_data = []
        FPS_data = []
        for j in range(2):
            compile_and_flash_into_board(j)
            if (j == 0):
                EDF_data = debug_and_read_data(taskset, hyperperiod, j)
            else:
                FPS_data = debug_and_read_data(taskset, hyperperiod, j)
        save_data(taskset, EDF_data, FPS_data, "U_"+ str(90) +"_hyper_113400000_3_6_armonic_10_200/U_"+ str(90) +"_hyper_113400000_3_6_armonic_10_200", i, hyperperiod)
    # for i in range(1, 501):
    #     taskset = []
    #     taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM, EDF_schedulable, FPS_schedulable, hyperperiod = import_taskset(taskset, i, "hyper_113400000_3_6_armonic_10_100.csv")
    #     make_adb_file(taskset, hyperperiod)
    #     EDF_data = []
    #     FPS_data = []
    #     for j in range(2):
    #         compile_and_flash_into_board(j)
    #         if (j == 0):
    #             EDF_data = debug_and_read_data(taskset, hyperperiod, j)
    #         else:
    #             FPS_data = debug_and_read_data(taskset, hyperperiod, j)
    #     save_data(taskset, EDF_data, FPS_data, "U_"+ str(90) +"_hyper_113400000_3_6_armonic_10_100/U_"+ str(90) +"_hyper_113400000_3_6_armonic_10_100", i, hyperperiod)


def full_harmonic():

    for i in range(1, 10001):
        taskset = []
        taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM, EDF_schedulable, FPS_schedulable, hyperperiod = import_taskset(taskset, i, "full_harmonic.csv")
        make_adb_file(taskset, hyperperiod)
        EDF_data = []
        FPS_data = []
        for j in range(2):
            compile_and_flash_into_board(j)
            if (j == 0):
                EDF_data = debug_and_read_data(taskset, hyperperiod, j)
            else:
                FPS_data = debug_and_read_data(taskset, hyperperiod, j)
        save_data(taskset, EDF_data, FPS_data, "Full_Harmonic/full_harmonic", i, hyperperiod)

def semi_harmonic():

    for i in range(1, 1001):
        taskset = []
        taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM, EDF_schedulable, FPS_schedulable, hyperperiod = import_taskset(taskset, i, "semi_harmonic.csv")
        make_adb_file(taskset, hyperperiod)
        EDF_data = []
        FPS_data = []
        for j in range(2):
            compile_and_flash_into_board(j)
            if (j == 0):
                EDF_data = debug_and_read_data(taskset, hyperperiod, j)
            else:
                FPS_data = debug_and_read_data(taskset, hyperperiod, j)
        save_data(taskset, EDF_data, FPS_data, "Semi_Harmonic/semi_harmonic", i, hyperperiod)

def U_90_log_uniform():

    for i in range(1, 1001):
        taskset = []
        taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM, EDF_schedulable, FPS_schedulable, hyperperiod = import_taskset(taskset, i, "U_90_log_uniform.csv")
        make_adb_file(taskset, hyperperiod)
        EDF_data = []
        FPS_data = []
        for j in range(2):
            compile_and_flash_into_board(j)
            if (j == 0):
                EDF_data = debug_and_read_data(taskset, hyperperiod, j)
            else:
                FPS_data = debug_and_read_data(taskset, hyperperiod, j)
        save_data(taskset, EDF_data, FPS_data, "U_90_log_uniform/U_90_log_uniform", i, hyperperiod)



def single_experiment(location, number, time):

    taskset = []
    taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM, EDF_schedulable, FPS_schedulable, hyperperiod = import_taskset(
            taskset, number, location)

    print(taskset)

    hyperperiod = time

    make_adb_file(taskset, hyperperiod)
    EDF_data = []
    FPS_data = []
    for j in range(2):
        compile_and_flash_into_board(j)
        if (j == 0):
            EDF_data = debug_and_read_data(taskset, hyperperiod, j)
        else:
            FPS_data = debug_and_read_data(taskset, hyperperiod, j)

    save_data(taskset, EDF_data, FPS_data, "single_experiment_no_repetition_", number, hyperperiod)

##########
## Main ##
##########

#buttazzo_experiments_preemptions()
#single_experiment("buttazzo_preemptions_no_repetition.csv", 4500, 1200000000)

U_90_log_uniform()

#buttazzo_experiments_preemptions_no_repetition ()

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



