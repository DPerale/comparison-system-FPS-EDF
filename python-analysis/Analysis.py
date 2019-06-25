from subprocess import Popen, PIPE
from random import randint, random
import numpy as np

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


#####################
## File management ##
#####################

def register_to_file(taskset, utilization, busy_period, first_DM_miss, schedulable, hyperperiod, name):
    tasksets_file = open(name, 'a')
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




###################
## MAST Analysis ##
###################

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






#######################
## Support functions ##
#######################

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


def calculate_hyperperiod (taskset):
    periods = []
    for i in range (len(taskset)):
        periods.append(taskset[i][1])
    lcm = np.lcm.reduce(periods, dtype='int128')
    return lcm







#######################
## Tasksets creation ##
#######################

def create_harmonic_taskset ():
    a = 0

def create_random_taskset_between_two_periods (num_tasks, low, high, utilization):
    taskset = []
    periods = []
    for i in range (num_tasks):
        periods.append(randint(low,high)*1000)
    periods.sort()
    for i in range (num_tasks):
        taskset.append ([(num_tasks - i), periods[i], periods[i], i+1, 0])
    UUnifast(taskset, utilization)
    return taskset


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






################
## TEST TYPES ##
################

def buttazzo_experiments_preemptions ():
    utilization = 0.9
    for i in range (2,11):
        for j in range(1000):
            taskset = create_random_taskset_between_two_periods(i*2, 10, 100, utilization)
            #hyperperiod = calculate_hyperperiod(taskset)
            busy_period, first_DM_miss, schedulable = MAST_EDF_Analysis(taskset)
            register_to_file(taskset, utilization, busy_period, first_DM_miss, schedulable, 1000000, "../workspace/buttazzo.csv")

    for i in range (10):
        utilization = 0.5 + i*0.05
        for j in range(1000):
            taskset = create_random_taskset_between_two_periods(10, 10, 100, utilization)
            #hyperperiod = calculate_hyperperiod(taskset)
            busy_period, first_DM_miss, schedulable = MAST_EDF_Analysis(taskset)
            register_to_file(taskset, utilization, busy_period, first_DM_miss, schedulable, 1000000, "../workspace/buttazzo.csv")




##########
## Main ##
##########

buttazzo_experiments_preemptions()



























































