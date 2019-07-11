from subprocess import Popen, PIPE
from random import randint, random
import numpy as np
import math

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

def create_file(name, first_row):
    file = open (name, 'w')
    file.write (first_row + "\n")
    file.close()

def register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable, FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task, utilization_context_switch, utilization_clock, hyperperiod, name):

    # Manca utilizzazione clock
    # utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i
    tasksets_file = open(name, 'a')
    tasksets_file.write(str(utilization)+";"+str(EDF_busy_period)+";"+str(FPS_busy_period)+";"+str(EDF_first_DM_miss)+";"+str(EDF_schedulable)+";"+str(FPS_schedulable)+";"+str(hyperperiod)+";")
    for i in range(len(taskset)):
        tasksets_file.write(str(taskset[i][0])+","+str(taskset[i][1])+","+str(taskset[i][2])+","+str(taskset[i][3])+","+str(taskset[i][4])+","+str(EDF_response_time[i])+","+str(FPS_response_time[i])+","+str(FPS_deadline_miss_task[i])+","+str(utilization_context_switch[i])+","+str(utilization_clock[i])+";")
    tasksets_file.write("\n")
    tasksets_file.close()


def create_MAST_input_file_EDF(taskset):
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
        MAST_file.write("                Deadline    => " + str(taskset[i][1]) + ",\n")
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
        MAST_file.write("                 Period => " + str(taskset[i][2]) + ")),\n")
        MAST_file.write("        Internal_Events => (\n")
        MAST_file.write("                (Type   => regular,\n")
        MAST_file.write("                 name   => O" + str(i + 1) + ",\n")
        MAST_file.write("                 Timing_Requirements => (\n")
        MAST_file.write("                         Type             => Hard_Global_Deadline,\n")
        MAST_file.write("                         Deadline         => " + str(taskset[i][1]) + ",\n")
        MAST_file.write("                         referenced_event => E" + str(i + 1) + "))),\n")
        MAST_file.write("        Event_Handlers => (\n")
        MAST_file.write("                (Type                => Activity,\n")
        MAST_file.write("                 Input_Event         => E" + str(i + 1) + ",\n")
        MAST_file.write("                 Output_Event        => O" + str(i + 1) + ",\n")
        MAST_file.write("                 Activity_Operation  => C" + str(i + 1) + ",\n")
        MAST_file.write("                 Activity_Server     => SC" + str(i + 1) + ")));\n")
    MAST_file.close()

def create_MAST_input_file_FPS(taskset):
    MAST_file = open("../MASTinput.txt", "w")
    MAST_file.write("Model (\n")
    MAST_file.write("   Model_Name  => FPS_RTA_CALCULUS,\n")
    MAST_file.write("   Model_Date  => 2019-01-01);\n")
    MAST_file.write("\n")
    MAST_file.write("Processing_Resource (\n")
    MAST_file.write("        Type 			      => Fixed_Priority_Processor,\n")
    MAST_file.write("        Name                 => Processor_1,\n")
    MAST_file.write("        Worst_Context_Switch => 9);\n")
    MAST_file.write("\n")

    for i in range(len(taskset)):
        MAST_file.write("Scheduling_Server (\n")
        MAST_file.write("        Type                    => Fixed_Priority,\n")
        MAST_file.write("        Name                    => SC" + str(i + 1) + ",\n")
        MAST_file.write("        Server_Sched_Parameters => (\n")
        MAST_file.write("                Type        => Fixed_Priority_Policy,\n")
        MAST_file.write("                The_Priority    => " + str(taskset[i][0]) + ",\n")
        MAST_file.write("                Preassigned => No),\n")
        MAST_file.write("        Server_Processing_Resource  => Processor_1);\n")

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
        MAST_file.write("                         Deadline         => " + str(taskset[i][1]) + ",\n")
        MAST_file.write("                         referenced_event => E" + str(i + 1) + "))),\n")
        MAST_file.write("        Event_Handlers => (\n")
        MAST_file.write("                (Type                => Activity,\n")
        MAST_file.write("                 Input_Event         => E" + str(i + 1) + ",\n")
        MAST_file.write("                 Output_Event        => O" + str(i + 1) + ",\n")
        MAST_file.write("                 Activity_Operation  => C" + str(i + 1) + ",\n")
        MAST_file.write("                 Activity_Server     => SC" + str(i + 1) + ")));\n")
    MAST_file.close()

###################
## MAST Analysis ##
###################

def MAST_EDF_Analysis (taskset):

    busy_period = -1
    first_DM_miss = 0
    schedulable = -1
    response_time = []
    i = 0

    create_MAST_input_file_EDF(taskset)

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
        if "ResponseTime:" in line.decode():
            s = line.decode().split(" ")
            response_time.append(float(s[1]))
            i = i+1

    return busy_period, first_DM_miss, schedulable, response_time


def MAST_FPS_Analysis (taskset):
    busy_period = -1
    schedulable = -1
    response_time = []
    deadline_miss_task = []
    i = 0

    create_MAST_input_file_FPS(taskset)

    command = ["../mast/mast_analysis/mast_analysis classic_rm ../MASTinput.txt ../MASTinput.out"]
    MAST = Popen(command, shell=True, stdout=PIPE, stdin=PIPE)

    while True and MAST.poll() == None:
        line = MAST.stdout.readline()
        if "Schedulable" in line.decode():
            s = line.decode().split(" ")
            schedulable = int(s[1])
        if "L:" in line.decode():
            s = line.decode().split(" ")
            busy_period = float(s[1])
        if "ResponseTime:" in line.decode():
            s = line.decode().split(" ")
            response_time.append(float(s[1]))
            if (response_time [i] > taskset[i][1]):
                deadline_miss_task.append(1)
            else:
                deadline_miss_task.append(0)
            i = i + 1

    return busy_period, schedulable, response_time, deadline_miss_task






#######################
## Support functions ##
#######################

def UUnifast (taskset, utilization):
    utilization_context_switch = []
    utilization_clock = []

    sumU = utilization

    # Utilization of context switch overhead
    for i in range (len(taskset)):
        sumU = sumU - (18 / taskset[i][2])
        utilization_context_switch.append((18 / taskset[i][2]))

    # Utilization of clock on wakeup tasks
    for i in range (len(taskset)):
        sumU = sumU - (22.2 / taskset[i][2])
        utilization_clock.append((22.2 / taskset[i][2]))

    # Utilization of work
    for i in range (1,len(taskset)):
        nextSumU = sumU * pow(random(), (1 / (len(taskset)-i)))
        while (sumU - nextSumU) >= 1:
            nextSumU = sumU * pow(random(), (1 / (len(taskset)-i)))
        taskset[i-1][4] = int((sumU - nextSumU) * taskset[i-1][2])
        sumU = nextSumU

    taskset[len(taskset)-1][4] = int(sumU * taskset[len(taskset)-1][2])

    return utilization_context_switch, utilization_clock

def calculate_hyperperiod (taskset):
    periods = []
    for i in range (len(taskset)):
        periods.append(taskset[i][2])
    lcm = np.lcm.reduce(periods, dtype='int128')
    return lcm


# def calculate_overhead_by_clock (taskset, EDF_busy_period, FPS_busy_period, FPS_response_time, interference_one_clock):
#
#     EDF_task_and_times = {}
#     FPS_task_and_times = {}
#     EDF_counting_clock_interference = []
#     FPS_counting_clock_interference = []
#     EDF_counting_clock_interference_assolute = []
#     FPS_counting_clock_interference_assolute = []
#     for task in range(len(taskset)):
#         EDF_counting_clock_interference.append(1)
#         FPS_counting_clock_interference.append(1)
#         EDF_counting_clock_interference_assolute.append(0)
#         FPS_counting_clock_interference_assolute.append(0)
#     for task in range (len(taskset)):
#         time_period = taskset[task][2]
#         while time_period < max(EDF_busy_period,FPS_busy_period):
#             if time_period <= EDF_busy_period:
#                 if time_period in EDF_task_and_times:
#                     EDF_task_and_times[time_period].append(task)
#                 else:
#                     EDF_task_and_times[time_period] = [task]
#                 EDF_counting_clock_interference [task] = EDF_counting_clock_interference[task] + 1
#             if time_period <= FPS_busy_period:
#                 if time_period in FPS_task_and_times:
#                     FPS_task_and_times[time_period].append(task)
#                 else:
#                     FPS_task_and_times[time_period] = [task]
#                 FPS_counting_clock_interference[task] = FPS_counting_clock_interference[task] + 1
#             time_period = time_period + taskset[task][2]
#
#     EDF_counting_clock_interference_weighted = []
#     FPS_counting_clock_interference_weighted = []
#     for task in range(len(taskset)):
#         EDF_counting_clock_interference_weighted.append(1/len(taskset))
#         FPS_counting_clock_interference_weighted.append(1/len(taskset))
#
#     for values in EDF_task_and_times:
#         for i in range(len(EDF_task_and_times [values])):
#             EDF_counting_clock_interference_weighted [EDF_task_and_times [values] [i]] = EDF_counting_clock_interference_weighted [EDF_task_and_times [values] [i]] + 1/ len(EDF_task_and_times [values])
#
#     for values in FPS_task_and_times:
#         for i in range(len(FPS_task_and_times [values])):
#             if FPS_response_time[i] < taskset[i][2]:
#                 FPS_counting_clock_interference_weighted [FPS_task_and_times [values] [i]] = FPS_counting_clock_interference_weighted [FPS_task_and_times [values] [i]] + 1/ len(FPS_task_and_times [values])
#
#     for task in range (len(taskset)):
#         EDF_counting_clock_interference_assolute[task] = math.ceil(interference_one_clock * (EDF_counting_clock_interference_weighted[task] / EDF_counting_clock_interference[task]))
#         FPS_counting_clock_interference_assolute[task] = math.ceil(interference_one_clock * (FPS_counting_clock_interference_weighted[task] / FPS_counting_clock_interference[task]))
#
#     return EDF_counting_clock_interference_assolute, FPS_counting_clock_interference_assolute
#
# def subtract_overhead_by_clock(taskset, EDF_counting_clock_interference_assolute, FPS_counting_clock_interference_assolute):
#     for i in range(len(taskset)):
#         a = 0


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
    utilization_context_switch, utilization_clock = UUnifast(taskset, utilization)
    return taskset, utilization_context_switch, utilization_clock


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
    utilization_context_switch = UUnifast(taskset,utilization)
    return taskset, utilization_context_switch






################
## TEST TYPES ##
################

def buttazzo_experiments_preemptions ():
    utilization = 0.9
    create_file("../workspace/buttazzo_preemptions.csv", "utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i,utilization_clock_i")
    for i in range (2,11):
        for j in range(1000):
            taskset, utilization_context_switch, utilization_clock = create_random_taskset_between_two_periods(i*2, 10, 100, utilization)
            #hyperperiod = calculate_hyperperiod(taskset)
            EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
            FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
            #EDF_counting_clock_interference_assolute, FPS_counting_clock_interference_assolute = calculate_overhead_by_clock(taskset, EDF_busy_period, FPS_busy_period, FPS_response_time, 977)
            register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable, FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task, utilization_context_switch, utilization_clock, 1000000, "../workspace/buttazzo_preemptions.csv")

    for i in range (10):
        utilization = 0.5 + i*0.05
        for j in range(1000):
            taskset, utilization_context_switch, utilization_clock = create_random_taskset_between_two_periods(10, 10, 100, utilization)
            #hyperperiod = calculate_hyperperiod(taskset)
            EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
            FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
            register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable, FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task, utilization_context_switch, utilization_clock, 1000000, "../workspace/buttazzo_preemptions.csv")




##########
## Main ##
##########

## Task (Prio, Dead, Period, ID, WCET)

buttazzo_experiments_preemptions()




























































