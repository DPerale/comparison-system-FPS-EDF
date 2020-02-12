from subprocess import Popen, PIPE
from random import randint, random, choice, choices, sample
import numpy as np
import math

task_hyper_113400000_10_100 = [10000,
15750,
18900,
20000,
22500,
25200,
26250,
28350,
30240,
33750,
35000,
37800,
39375,
40000,
42000,
45000,
45360,
47250,
50000,
50400,
52500,
54000,
56250,
56700,
60000,
60480,
63000,
64800,
65625,
67500,
70000,
70875,
72000,
75000,
75600,
78750,
81000,
84000,
84375,
87500,
90000,
90720,
94500,
100000]

task_hyper_113400000_10_200 = [10000,
15750,
18900,
20000,
22500,
25200,
26250,
28350,
30240,
33750,
35000,
37800,
39375,
40000,
42000,
45000,
45360,
47250,
50000,
50400,
52500,
54000,
56250,
56700,
60000,
60480,
63000,
64800,
65625,
67500,
70000,
70875,
72000,
75000,
75600,
78750,
81000,
84000,
84375,
87500,
90000,
90720,
94500,
100000,
100800,
101250,
105000,
108000,
112500,
113400,
118125,
120000,
126000,
129600,
131250,
135000,
140000,
141750,
150000,
151200,
157500,
162000,
168000,
168750,
175000,
180000,
181440,
189000,
196875,
200000  ]

task_hyper_113400000_longs = [405000,
420000,
450000,
453600,
472500,
504000,
506250,
525000,
540000,
567000,
590625,
600000,
630000,
648000,
675000,
700000,
708750,
756000,
787500,
810000,
840000,
900000,
907200,
945000
]

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

def register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable, FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task, utilization_context_switch, utilization_clock, utilization_support_function, hyperperiod, name):

    # Manca utilizzazione clock
    # utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i
    tasksets_file = open(name, 'a')
    tasksets_file.write(str(utilization)+";"+str(EDF_busy_period)+";"+str(FPS_busy_period)+";"+str(EDF_first_DM_miss)+";"+str(EDF_schedulable)+";"+str(FPS_schedulable)+";"+str(hyperperiod)+";")
    for i in range(len(taskset)):
        # print(taskset)
        # print(EDF_response_time)
        # print("FPS")
        # print(FPS_response_time)
        # print(FPS_deadline_miss_task)
        # print(utilization_context_switch)
        # print(utilization_clock)
        tasksets_file.write(str(taskset[i][0])+","+str(taskset[i][1])+","+str(taskset[i][2])+","+str(taskset[i][3])+","+str(taskset[i][4])+","+str(EDF_response_time[i])+","+str(FPS_response_time[i])+","+str(FPS_deadline_miss_task[i])+","+str(utilization_context_switch[i])+","+str(utilization_clock[i])+","+str(utilization_support_function[i])+";")
    tasksets_file.write("\n")
    tasksets_file.close()


def create_MAST_input_file_EDF(taskset):
    MAST_file = open("../MASTinputEDF.txt", "w")
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

    command = ["../mast/mast_analysis/mast_analysis edf_monoprocessor ../MASTinputEDF.txt ../MASTinput.out"]
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
    MAST.kill()
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
    MAST.kill()
    return busy_period, schedulable, response_time, deadline_miss_task






#######################
## Support functions ##
#######################

def UUnifast (taskset, utilization):
    utilization_context_switch = []
    utilization_clock = []
    utilization_support_function = []

    sumU = utilization

    # Utilization of context switch overhead
    for i in range (len(taskset)):
        sumU = sumU - (18 / taskset[i][2])
        utilization_context_switch.append((18 / taskset[i][2]))

    # Utilization of clock on wakeup tasks
    for i in range (len(taskset)):
        sumU = sumU - (22.2 / taskset[i][2])
        utilization_clock.append((22.2 / taskset[i][2]))

    # Utilization of overhead for support functions in task
    for i in range (len(taskset)):
        sumU = sumU - (16.43 / taskset[i][2])
        utilization_support_function.append((16.43 / taskset[i][2]))


    # Utilization of work
    for i in range (1,len(taskset)):
        nextSumU = sumU * pow(random(), (1 / (len(taskset)-i)))
        while (sumU - nextSumU) >= 1 or (sumU - nextSumU) == 0:
            nextSumU = sumU * pow(random(), (1 / (len(taskset)-i)))
        taskset[i-1][4] = int((sumU - nextSumU) * taskset[i-1][2])
        sumU = nextSumU

    taskset[len(taskset)-1][4] = int(sumU * taskset[len(taskset)-1][2])

    return utilization_context_switch, utilization_clock, utilization_support_function

def calculate_hyperperiod (taskset):
    periods = []
    for i in range (len(taskset)):
        periods.append(taskset[i][2])
    lcm = np.lcm.reduce(periods)

    return lcm

def calculate_hyperperiod_with_limit (taskset, max_hyperperiod):
    periods = []
    for i in range (len(taskset)):
        periods.append(taskset[i][2])
    #lcm = np.lcm.reduce(periods)
    # iterative lcm
    lcm = 1
    for i in range (len(taskset)):
        lcm = np.lcm.reduce([lcm, periods[i]])

        if lcm > max_hyperperiod:
            return max_hyperperiod+1
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
        periods.append(randint(low,high) * 1000)
    periods.sort()
    for i in range (num_tasks):
        taskset.append ([(num_tasks - i), periods[i], periods[i], i+1, 0])

    utilization_context_switch, utilization_clock, utilization_support_function = UUnifast(taskset, utilization)
    return taskset, utilization_context_switch, utilization_clock, utilization_support_function

def create_random_taskset_between_two_periods_with_max_hyperperiod (num_tasks, low, high, utilization, hyperperiod):
    soglia_iperperiodo = 160000000
    hyperperiod = 160000001
    taskset = []
    j = 0
    while hyperperiod > soglia_iperperiodo:
        taskset = []
        periods = []
        for i in range(num_tasks):
            periods.append(randint(low, high) * 1000)
        periods.sort()
        for i in range(num_tasks):
            taskset.append([(num_tasks - i), periods[i], periods[i], i + 1, 0])

        hyperperiod = calculate_hyperperiod_with_limit(taskset,soglia_iperperiodo)
        print(j)
        j=j+1
    import sys

    print(hyperperiod)
    utilization_context_switch, utilization_clock, utilization_support_function = UUnifast(taskset, utilization)
    return taskset, utilization_context_switch, utilization_clock, utilization_support_function


def create_random_taskset_between_two_periods_no_repetition (num_tasks, low, high, utilization):
    taskset = []
    periods = []

    i = 0
    while i < num_tasks:
        rand = randint(low, high) * 1000
        if rand not in periods:
            periods.append(rand)
            i = i+1
    periods.sort()
    for i in range (num_tasks):
        taskset.append ([(num_tasks - i), periods[i], periods[i], i+1, 0])

    utilization_context_switch, utilization_clock, utilization_support_function = UUnifast(taskset, utilization)
    return taskset, utilization_context_switch, utilization_clock, utilization_support_function


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

def create_taskset_hyper_113400000_10_100(num_tasks, utilization):
    taskset = []
    periods = []
    n_task_armonic = -1
    while n_task_armonic < 7 or n_task_armonic > 20:
        taskset = []
        periods = []
        i = 0
        while i < num_tasks:
            rand = task_hyper_113400000_10_100[randint(0, 43)]
            if rand not in periods:
                periods.append(rand)
                i = i + 1
        periods.sort()
        armonic = []
        for l in range(num_tasks - 1, 0, -1):
            for j in range(0, l):
                if periods[l] % periods[j] == 0:
                    armonic.append(periods[l])
                    armonic.append(periods[j])
        n_task_armonic = len(set(armonic))


    for i in range(num_tasks):
        taskset.append([(num_tasks - i), periods[i], periods[i], i + 1, 0])

    utilization_context_switch, utilization_clock, utilization_support_function = UUnifast(taskset, utilization)
    return taskset, utilization_context_switch, utilization_clock, utilization_support_function


def create_taskset_hyper_113400000_10_200_with_some_long (num_tasks, utilization):

    taskset = []
    periods = []
    n_task_armonic = -1
    while n_task_armonic<0 or n_task_armonic >2:
        taskset = []
        periods = []
        i = 0
        num_longs = randint(1,2)
        while i < (num_tasks-num_longs):
            rand = task_hyper_113400000_10_200[randint(0, len(task_hyper_113400000_10_200)-1)]
            if rand not in periods:
                periods.append(rand)
                i = i + 1
        i = 0
        while i < num_longs:
            rand = task_hyper_113400000_longs[randint(0, len(task_hyper_113400000_longs)-1)]
            if rand not in periods:
                periods.append(rand)
                i = i + 1
        periods.sort()
        armonic = []
        for l in range (num_tasks-1,0,-1):
            for j in range(0,l):
                if periods[l] % periods[j] == 0:
                    armonic.append(periods[l])
                    armonic.append(periods[j])
        n_task_armonic = len(set(armonic))

    for i in range(num_tasks):
        taskset.append([(num_tasks - i), periods[i], periods[i], i + 1, 0])

    utilization_context_switch, utilization_clock, utilization_support_function = UUnifast(taskset, utilization)
    return taskset, utilization_context_switch, utilization_clock, utilization_support_function


def create_taskset_harmonic(periods, utilization):
    taskset = []

    for i in range(20):
        taskset.append([(20 - i), periods[i], periods[i], i + 1, 0])
    utilization_context_switch, utilization_clock, utilization_support_function = UUnifast(taskset, utilization)
    return taskset, utilization_context_switch, utilization_clock, utilization_support_function

def create_taskset_log_uniform(low, high, size, utilization):
    taskset = []

    periods = np.exp(np.random.uniform(math.log(low), math.log(high), size))
    periods = [x * 1000 for x in sorted(np.array(periods, dtype=int))]

    for i in range (size):
        taskset.append([(size - i), periods[i], periods[i], i + 1, 0])
    utilization_context_switch, utilization_clock, utilization_support_function = UUnifast(taskset, utilization)
    return taskset, utilization_context_switch, utilization_clock, utilization_support_function


################
## TEST TYPES ##
################

def buttazzo_experiments_preemptions ():
    utilization = 0.9
    create_file("../workspace/buttazzo_preemptions.csv", "utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i,utilization_clock, utilization_support_function_i")
    for i in range (2,11):
        for j in range(1000):
            taskset, utilization_context_switch, utilization_clock, utilization_support_function = create_random_taskset_between_two_periods(i*2, 10, 100, utilization)
            #hyperperiod = calculate_hyperperiod(taskset)
            EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
            FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
            #EDF_counting_clock_interference_assolute, FPS_counting_clock_interference_assolute = calculate_overhead_by_clock(taskset, EDF_busy_period, FPS_busy_period, FPS_response_time, 977)
            register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable, FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task, utilization_context_switch, utilization_clock, utilization_support_function, 1000000, "../workspace/buttazzo_preemptions.csv")

    for i in range (10):
        utilization = 0.5 + i*0.05
        for j in range(1000):
            taskset, utilization_context_switch, utilization_clock, utilization_support_function = create_random_taskset_between_two_periods(10, 10, 100, utilization)
            #hyperperiod = calculate_hyperperiod(taskset)
            EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
            FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
            register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable, FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task, utilization_context_switch, utilization_clock, utilization_support_function, 1000000, "../workspace/buttazzo_preemptions.csv")

def buttazzo_experiments_preemptions_no_repetition ():
    utilization = 0.9
    create_file("../workspace/buttazzo_preemptions_no_repetition.csv", "utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i,utilization_clock, utilization_support_function_i")
    for i in range (2,11):
        for j in range(500):
            taskset, utilization_context_switch, utilization_clock, utilization_support_function = create_random_taskset_between_two_periods_no_repetition (i*2, 10, 100, utilization)
            #hyperperiod = calculate_hyperperiod(taskset)
            EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
            FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)

            #EDF_counting_clock_interference_assolute, FPS_counting_clock_interference_assolute = calculate_overhead_by_clock(taskset, EDF_busy_period, FPS_busy_period, FPS_response_time, 977)
            register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable, FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task, utilization_context_switch, utilization_clock, utilization_support_function, 1000000, "../workspace/buttazzo_preemptions_no_repetition.csv")

    for i in range (10):
        utilization = 0.5 + i*0.05
        for j in range(500):
            taskset, utilization_context_switch, utilization_clock, utilization_support_function = create_random_taskset_between_two_periods_no_repetition (10, 10, 100, utilization)
            #hyperperiod = calculate_hyperperiod(taskset)
            EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
            FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
            register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable, FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task, utilization_context_switch, utilization_clock, utilization_support_function, 1000000, "../workspace/buttazzo_preemptions_no_repetition.csv")


def U_90_hyper_113400000_10_100():
    utilization = 0.9
    create_file("../workspace/U_90_hyper_113400000.csv",
                "utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i,utilization_clock, utilization_support_function_i")

    for j in range(500):
        taskset, utilization_context_switch, utilization_clock, utilization_support_function = create_taskset_hyper_113400000_10_100(20, utilization)
        hyperperiod = calculate_hyperperiod(taskset)
        EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
        FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
        # EDF_counting_clock_interference_assolute, FPS_counting_clock_interference_assolute = calculate_overhead_by_clock(taskset, EDF_busy_period, FPS_busy_period, FPS_response_time, 977)

        register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable,
                         FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task,
                         utilization_context_switch, utilization_clock, utilization_support_function, hyperperiod,
                         "../workspace/U_90_hyper_113400000.csv")

def hyper_113400000_10_100_with_some_long():
    create_file("../workspace/hyper_113400000_10_200_with_some_long.csv",
                "utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i,utilization_clock, utilization_support_function_i")

    for i in range(4):
        utilization = 0.6 + (0.1 * i)
        for j in range(500):
            taskset, utilization_context_switch, utilization_clock, utilization_support_function = create_taskset_hyper_113400000_10_200_with_some_long (20, utilization)
            hyperperiod = calculate_hyperperiod(taskset)
            EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
            FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
            # EDF_counting_clock_interference_assolute, FPS_counting_clock_interference_assolute = calculate_overhead_by_clock(taskset, EDF_busy_period, FPS_busy_period, FPS_response_time, 977)

            register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable,
                             FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task,
                             utilization_context_switch, utilization_clock, utilization_support_function, hyperperiod,
                             "../workspace/hyper_113400000_10_200_with_some_long.csv")

def hyper_113400000_2_5_armonic():
    create_file("../workspace/hyper_113400000_0_1_armonic_10_200.csv",
                "utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i,utilization_clock, utilization_support_function_i")


    utilization = 0.9
    for j in range(500):
        print(j)
        taskset, utilization_context_switch, utilization_clock, utilization_support_function = create_taskset_hyper_113400000_10_200_with_some_long (20, utilization)
        hyperperiod = calculate_hyperperiod(taskset)
        EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
        FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
        # EDF_counting_clock_interference_assolute, FPS_counting_clock_interference_assolute = calculate_overhead_by_clock(taskset, EDF_busy_period, FPS_busy_period, FPS_response_time, 977)

        register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable,
                         FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task,
                         utilization_context_switch, utilization_clock, utilization_support_function, hyperperiod,
                         "../workspace/hyper_113400000_0_1_armonic_10_200.csv")

def full_harmonic():
    create_file("../workspace/full_harmonic.csv",
                "utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i,utilization_clock, utilization_support_function_i")

    taskset_periods = []
    for i in range(10000):
        taskset_periods.append([])
    for l in range(500):
        if l < 200:
            min_int = max_int = int(l / 50) + 2
        else:
            min_int = 2
            max_int = 5

        for i in range(10, 30):
            n = i
            t = 1
            taskset_periods[l * 20 + i - 10].append(n)
            while (t < 20 and n <= 500):
                if (l >= 200):
                    temp = n * randint(min_int, max_int)
                    if (temp != taskset_periods[l * 20 + i - 10][t - 1] and temp <= 1000):
                        n = temp
                        taskset_periods[l * 20 + i - 10].append(n)
                        t = t + 1
                else:
                    n = n * randint(min_int, max_int)
                    if (n <= 1000):
                        taskset_periods[l * 20 + i - 10].append(n)
                        t = t + 1

            if t < 19:
                t2 = t
                while (t < 20):
                    temp = choice(taskset_periods[l * 20 + i - 10][0:t2])
                    taskset_periods[l * 20 + i - 10].append(temp)
                    t = t + 1


    for i in range(10000):
        taskset_periods [i] = sorted([j * 1000 for j in taskset_periods[i]])

    print(taskset_periods[0])

    utilization = 0.9
    for i in range(10000):
        print(i)
        taskset, utilization_context_switch, utilization_clock, utilization_support_function = create_taskset_harmonic(taskset_periods[i], utilization)
        hyperperiod = calculate_hyperperiod(taskset)
        EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
        FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
        register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable,
                         FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task,
                         utilization_context_switch, utilization_clock, utilization_support_function, hyperperiod,
                         "../workspace/full_harmonic.csv")


def semi_harmonic():
    create_file("../workspace/semi_harmonic.csv",
                "utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i,utilization_clock, utilization_support_function_i")

    def isPrime(n):
        if (n <= 1):
            return False
        if (n <= 3):
            return True
        if (n % 2 == 0 or n % 3 == 0):
            return False
        i = 5
        while (i * i <= n):
            if (n % i == 0 or n % (i + 2) == 0):
                return False
            i = i + 6
        return True

    reintroduction = True
    taskset_periods = []
    for i in range(1000):
        taskset_periods.append([])
    for z in range(50):
        if z == 25:
            reintroduction = False
        for i in range(10, 30):
            n = i
            t = 0
            possibleChoiches = []
            possibleChoiches.append(n)
            while (n < 1000):
                n = n + i
                possibleChoiches.append(n)
            n2 = 4
            n3 = 1
            n5 = 2
            n7 = 1
            nmin = 0
            min_i = i
            if (isPrime(i)):
                nmin = 1
            else:
                if (i == 22 or i == 26):
                    nmin = 1
                    min_i = int(i / 2)
                else:
                    if (i == 27 or i == 18):
                        n2 = 5
                        n3 = 3
                        n5 = 2
                    else:
                        n2 = 6
                        n3 = 2
                        n5 = 2
            numbers = []
            for f in range((n2 + 1)):
                for j in range((n3 + 1)):
                    for l in range((n5 + 1)):
                        for m in range((n7 + 1)):
                            for o in range((nmin + 1)):
                                if ((2 ** f) * (3 ** j) * (5 ** l) * (7 ** m) * (min_i ** o)) >= 10 and (
                                        (2 ** f) * (3 ** j) * (5 ** l) * (7 ** m) * (min_i ** o)) < 1000:
                                    numbers.append(((2 ** f) * (3 ** j) * (5 ** l) * (7 ** m) * (min_i ** o)))
            common = sorted(list(set(possibleChoiches).intersection(numbers)))
            if (len(common) >= 20):
                if reintroduction:
                    taskset_periods[(z * 20) + (i - 10)] = sorted(choices(common, k=20))
                else:
                    taskset_periods[(z * 20) + (i - 10)] = sorted(sample(common, 20))
                t = 20
            else:
                taskset_periods[(z * 20) + (i - 10)] = common
                t = len(common)
            if (t < 20):
                t2 = t
                while (t < 20):
                    temp = choice(taskset_periods[(z * 20) + (i - 10)][0:t2])
                    taskset_periods[(z * 20) + (i - 10)].append(temp)
                    t = t + 1
    for i in range(1000):
        taskset_periods [i] = sorted([j * 1000 for j in taskset_periods[i]])



    utilization = 0.9
    for i in range(1000):
        print(i)
        taskset, utilization_context_switch, utilization_clock, utilization_support_function = create_taskset_harmonic(taskset_periods[i], utilization)
        hyperperiod = calculate_hyperperiod(taskset)
        EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
        FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
        register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable,
                         FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task,
                         utilization_context_switch, utilization_clock, utilization_support_function, hyperperiod,
                         "../workspace/semi_harmonic.csv")

def U_90_log_uniform():
    create_file("../workspace/U_90_log_uniform.csv",
                "utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i,utilization_clock, utilization_support_function_i")


    utilization = 0.9
    for j in range(1000):
        print(j)
        taskset, utilization_context_switch, utilization_clock, utilization_support_function = create_taskset_log_uniform(10, 100, 20, utilization)
        hyperperiod = 1000000
        EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
        FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)

        # EDF_counting_clock_interference_assolute, FPS_counting_clock_interference_assolute = calculate_overhead_by_clock(taskset, EDF_busy_period, FPS_busy_period, FPS_response_time, 977)

        register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable,
                         FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task,
                         utilization_context_switch, utilization_clock, utilization_support_function, hyperperiod,
                         "../workspace/U_90_log_uniform.csv")

def U_99_hyper_113400000_10_100():
    utilization = 0.99
    create_file("../workspace/U_99_hyper_113400000_10_100.csv",
                "utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i,utilization_clock, utilization_support_function_i")

    for j in range(500):
        print(j)
        taskset, utilization_context_switch, utilization_clock, utilization_support_function = create_taskset_hyper_113400000_10_100(20, utilization)
        hyperperiod = calculate_hyperperiod(taskset)
        EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
        FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
        # EDF_counting_clock_interference_assolute, FPS_counting_clock_interference_assolute = calculate_overhead_by_clock(taskset, EDF_busy_period, FPS_busy_period, FPS_response_time, 977)

        register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable,
                         FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task,
                         utilization_context_switch, utilization_clock, utilization_support_function, hyperperiod,
                         "../workspace/U_99_hyper_113400000_10_100.csv")


def U_100_hyper_113400000_10_100():
    utilization = 1.00
    create_file("../workspace/U_100_hyper_113400000_10_100.csv",
                "utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i,utilization_clock, utilization_support_function_i")

    for j in range(500):
        print(j)
        taskset, utilization_context_switch, utilization_clock, utilization_support_function = create_taskset_hyper_113400000_10_100(20, utilization)
        hyperperiod = calculate_hyperperiod(taskset)
        EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
        FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
        # EDF_counting_clock_interference_assolute, FPS_counting_clock_interference_assolute = calculate_overhead_by_clock(taskset, EDF_busy_period, FPS_busy_period, FPS_response_time, 977)

        register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable,
                         FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task,
                         utilization_context_switch, utilization_clock, utilization_support_function, hyperperiod,
                         "../workspace/U_100_hyper_113400000_10_100.csv")


##########
## Main ##
##########

## Task (Prio, Dead, Period, ID, WCET)

#buttazzo_experiments_preemptions()
#U_100_hyper_113400000_10_100()

