import csv
import os
import subprocess
from threading import Thread
from subprocess import Popen, PIPE
from datetime import datetime
import time

####################
## Import Taskset ##     # Da mettere su file principale
####################

def import_taskset(taskset):
    with open('../workspace/results_prova.csv') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=';')
        line_count = 0
        for row in csv_reader:
            for task in range (len(row)-3):
                #print(row[task+2])
                string_task = row[task+2].split(",")
                task = [string_task[0],
                        string_task[1],
                        string_task[2],
                        string_task[3],
                        string_task[4]]
                taskset.append (task)
    return taskset

##############################
## Make ADB file to compile ##  # Da mettere su file principale?
##############################

def make_adb_file (taskset, hyperPeriod):
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
    os.system("gprbuild --target=arm-eabi -d -P/home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01.gpr /home/aquox/Scrivania/Arm/edf-ravenscar-arm/src/unit01.adb -largs -Wl,-Map=map.txt")
    os.system("arm-eabi-objdump /home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01 -h")
    os.system("arm-eabi-objcopy -O binary /home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01 /home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01.bin")
    os.system("st-flash write /home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01.bin 0x08000000")


##################################################
##  Debug program and save results into a file  ##
##################################################

##  Separate Thread for call the st-util tool
class st_util_thread (Thread):
    def __init__(self):
        Thread.__init__(self)
    def run(self):
        subprocess.call(['st-util'], shell=True)

def debug_and_save_data (taskset, hyperperiod):
    st_util = st_util_thread()
    st_util.start()
    command =["arm-eabi-gdb /home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01"]
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
            debugger.stdin.write("break s-bbthqu.adb:134\n".encode())
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
                    print ("DM_LINE" + str(DM_Line))
                    debugger.stdin.write(("p Task_Table (" + str(i + 1) + ").Execution\n").encode())
                    debugger.stdin.flush()
                    Execution_Line = debugger.stdout.readline().decode().split(" ")
                    print("Execution_Line" + str(Execution_Line))
                    debugger.stdin.write(("p Task_Table (" + str(i + 1) + ").Preemption\n").encode())
                    debugger.stdin.flush()
                    Preemption_Line = debugger.stdout.readline().decode().split(" ")
                    print("Preemption_Line" + str(Preemption_Line))
                    debugger.stdin.write(("c\n").encode())
                    debugger.stdin.flush()
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

    #debugger.stdin.write("monitor reset halt".encode())
    #debugger.stdin.write("c".encode())
    #debugger.communicate (["tar extended-remote :4242"])
    #print(prova)
    #subprocess.call(['arm-eabi-gdb /home/aquox/Scrivania/Arm/edf-ravenscar-arm/unit01'], shell=True)

##########
## Main ##
##########

# taskset = []
# taskset = import_taskset(taskset)
# make_adb_file(taskset, 952560000)
#
# utilization = 0
# utilization2 = 0
# for task in range(len(taskset)):
#     work = int((float(taskset[task][4]) - 2) * 180 / 17)
#     print (work)
#     utilization = utilization + (work*17/180) / float(taskset[task][1])
#     utilization2 = utilization2 + float(taskset[task][4])/float(taskset[task][1])
# print (utilization)
# print (utilization2)
#
# # compile_and_flash_into_board()
# debug_and_save_data(taskset, 952560000)






task_periods_for_non_harmonic = [   10000, # Short (0,28)
                                    10584,
                                    11340,
                                    12150,
                                    13230,
                                    14112,
                                    15120,
                                    16000,
                                    17280,
                                    18375,
                                    21168,
                                    22680,
                                    24192,
                                    26250,
                                    28224,
                                    31500,
                                    33750,
                                    36288,
                                    39375,
                                    42000,
                                    45000,
                                    48000,
                                    52500,
                                    55125,
                                    59535,
                                    61250,
                                    70875,
                                    77760,
                                    79380,
                                    189000, # Medium (29,57)
                                    190512,
                                    194400,
                                    198450,
                                    201600,
                                    202500,
                                    211680,
                                    212625,
                                    217728,
                                    220500,
                                    226800,
                                    236250,
                                    238140,
                                    240000,
                                    243000,
                                    252000,
                                    254016,
                                    264600,
                                    272160,
                                    280000,
                                    282240,
                                    294000,
                                    297675,
                                    302400,
                                    303750,
                                    317520,
                                    330750,
                                    340200,
                                    352800,
                                    420000, # Long (58,86)
                                    423360,
                                    425250,
                                    432000,
                                    441000,
                                    453600,
                                    470400,
                                    472500,
                                    476280,
                                    486000,
                                    490000,
                                    496125,
                                    504000,
                                    508032,
                                    529200,
                                    540000,
                                    544320,
                                    551250,
                                    560000,
                                    567000,
                                    588000,
                                    595350,
                                    604800,
                                    607500,
                                    630000,
                                    635040,
                                    648000,
                                    661500,
                                    680400    ]



from random import randint, random
import numpy as np

# DA CHIAMARE SU MAIN NON SU MAST_INPUT_FILE
def register_to_file(taskset, utilization, busy_period, first_DM_miss, schedulable, hyperperiod):
    tasksets_file = open("../workspace/tasksets.csv", 'a')
    tasksets_file.write(str(utilization)+";"+str(busy_period)+";"+str(first_DM_miss)+";"+str(schedulable)+";"+str(hyperperiod)+";")
    for i in range(len(taskset)):
        tasksets_file.write(str(taskset[i][0])+","+str(taskset[i][1])+","+str(taskset[i][2])+","+str(taskset[i][3])+","+str(taskset[i][4])+";")
    tasksets_file.write("\n")


def create_MAST_input_file(taskset):
    MAST_file = open("../MASTinput.txt", "w")
    MAST_file.write("Model (\n")
    MAST_file.write("   Model_Name  => EDF_RTA_CALCULUS,\n")
    MAST_file.write("   Model_Date  => 2019-01-01);\n")
    MAST_file.write("\n")
    MAST_file.write("Processing_Resource (\n")
    MAST_file.write("        Type => Regular_Processor,\n")
    MAST_file.write("        Name => Processor_1);\n")
    MAST_file.write("\n")
    MAST_file.write("Scheduler (\n")
    MAST_file.write("        Type  => Primary_Scheduler,\n")
    MAST_file.write("        Name  => EDF_Scheduler,\n")
    MAST_file.write("        Host  => Processor_1,\n")
    MAST_file.write("        Policy =>\n")
    MAST_file.write("           (Type => EDF,\n")
    MAST_file.write("      Worst_Context_Switch => 9));\n")

    for i in range(len(taskset)):
        MAST_file.write("Scheduling_Server (\n")
        MAST_file.write("        Type                    => Regular,\n")
        MAST_file.write("        Name                    => SC" + str(i + 1) + ",\n")
        MAST_file.write("        Server_Sched_Parameters => (\n")
        MAST_file.write("                Type        => EDF_policy,\n")
        MAST_file.write("                Deadline    => " + str(taskset[i][2]) + ",\n")
        MAST_file.write("                Preassigned => No),\n")
        MAST_file.write("        Scheduler               => EDF_Scheduler);\n")

    for i in range(len(taskset)):
        MAST_file.write("Operation (\n")
        MAST_file.write("        Type    => Simple,\n")
        MAST_file.write("        Name    => C" + str(i + 1) + ",\n")
        MAST_file.write("        Worst_Case_Execution_Time => " + str(taskset[i][4]) + ");\n")

    for i in range(len(taskset)):
        MAST_file.write("Transaction (\n")
        MAST_file.write("        Type    => Regular,\n")
        MAST_file.write("        Name    => T" + str(i + 1) + ",\n")
        MAST_file.write("        External_Events => (\n")
        MAST_file.write("                (Type   => Periodic,\n")
        MAST_file.write("                 Name   => E" + str(i + 1) + ",\n")
        MAST_file.write("                 Period => " + str(taskset[i][1]) + ")),\n")
        MAST_file.write("        Internal_Events => (\n")
        MAST_file.write("                (Type   => regular,\n")
        MAST_file.write("                 name   => O" + str(i + 1) + ",\n")
        MAST_file.write("                 Timing_Requirements => (\n")
        MAST_file.write("                         Type             => Hard_Global_Deadline,\n")
        MAST_file.write("                         Deadline         => " + str(taskset[i][2]) + ",\n")
        MAST_file.write("                         referenced_event => E" + str(i + 1) + "))),\n")
        MAST_file.write("        Event_Handlers => (\n")
        MAST_file.write("                (Type                => Activity,\n")
        MAST_file.write("                 Input_Event         => E" + str(i + 1) + ",\n")
        MAST_file.write("                 Output_Event        => O" + str(i + 1) + ",\n")
        MAST_file.write("                 Activity_Operation  => C" + str(i + 1) + ",\n")
        MAST_file.write("                 Activity_Server     => SC" + str(i + 1) + ")));\n")

def MAST_EDF_Analysis (taskset):

    busy_period = -1
    first_DM_miss = 0
    schedulable = -1

    create_MAST_input_file(taskset)

    command = ["../mast/mast_analysis/mast_analysis edf_monoprocessor ../MASTinput.txt ../MASTinput.out"]
    MAST = Popen(command, shell=True, stdout=PIPE, stdin=PIPE)

    while True and MAST.poll() == None:
        line = MAST.stdout.readline()
        if "FirstDeadlineMissAfter" in line.decode():
            s = line.decode().split(" ")
            first_DM_miss = float(s[1])
        if "Schedulable" in line.decode():
            s = line.decode().split(" ")
            schedulable = int(s[1])
        if "L:" in line.decode():
            s = line.decode().split(" ")
            busy_period = float(s[1])

    return busy_period, first_DM_miss, schedulable





def MAST_FPS_Analysis ():
    a = 0

def create_harmonic_taskset ():
    a = 0



def UUnifast (taskset, utilization):
    sumU = utilization

    # Utilization of context switch overhead
    for i in range (len(taskset)):
        sumU = sumU - (18 / taskset[i][1])

    # Utilization of work
    for i in range (1,len(taskset)):
        nextSumU = sumU * pow(random(), (1 / (len(taskset)-i)))
        while (sumU - nextSumU) >= 1:
            nextSumU = sumU * pow(random(), (1 / (len(taskset)-i)))
        taskset[i-1][4] = int((sumU - nextSumU) * taskset[i-1][1])
        sumU = nextSumU

    taskset[len(taskset)-1][4] = int(sumU * taskset[len(taskset)-1][1])



def create_non_harmonic_taskset (num_tasks_per_type, utilization):

    taskset = []

    periods = []
    for i in range (3):
        task_per_type = 0
        while task_per_type < num_tasks_per_type:
            pick = task_periods_for_non_harmonic[randint(0+(29*i), 28+(29*i))]
            if pick not in taskset:
                periods.append(pick)
                task_per_type = task_per_type + 1
    periods.sort()

    for i in range (num_tasks_per_type*3):
        taskset.append ([(num_tasks_per_type*3 - i), periods[i], periods[i], i+1, 0])

    UUnifast(taskset,utilization)

    return taskset


def calculate_hyperperiod (taskset):
    periods = []
    for i in range (len(taskset)):
        periods.append(taskset[i][1])
    lcm = np.lcm.reduce(periods)
    return lcm

##########
## Main ##
##########

num_tasks_per_type = 10
utilization = 0.80

taskset = create_non_harmonic_taskset(num_tasks_per_type, utilization)
hyperperiod = calculate_hyperperiod (taskset)
busy_period, first_DM_miss, schedulable = MAST_EDF_Analysis(taskset)
register_to_file(taskset, utilization, busy_period, first_DM_miss, schedulable, hyperperiod)
























































