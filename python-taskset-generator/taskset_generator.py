from random import randint
from support_functions import UUnifast
import numpy as np
import math

# periods generated with hyperperiod choosing method (113400000 microseconds, range [10,100] ms)
task_hyper_113400000_10_100 = [10000, 15750, 18900, 20000, 22500, 25200, 26250, 28350, 30240, 33750, 35000, 37800,
                               39375, 40000, 42000, 45000, 45360, 47250, 50000, 50400, 52500, 54000, 56250, 56700,
                               60000, 60480, 63000, 64800, 65625, 67500, 70000, 70875, 72000, 75000, 75600, 78750,
                               81000, 84000, 84375, 87500, 90000, 90720, 94500, 100000]

# periods generated with hyperperiod choosing method (113400000 microseconds, range [10,200] ms)
task_hyper_113400000_10_200 = [10000, 15750, 18900, 20000, 22500, 25200, 26250, 28350, 30240, 33750, 35000, 37800,
                               39375, 40000, 42000, 45000, 45360, 47250, 50000, 50400, 52500, 54000, 56250, 56700,
                               60000, 60480, 63000, 64800, 65625, 67500, 70000, 70875, 72000, 75000, 75600, 78750,
                               81000, 84000, 84375, 87500, 90000, 90720, 94500, 100000, 100800, 101250, 105000, 108000,
                               112500, 113400, 118125, 120000, 126000, 129600, 131250, 135000, 140000, 141750, 150000,
                               151200, 157500, 162000, 168000, 168750, 175000, 180000, 181440, 189000, 196875, 200000]

# periods generated with hyperperiod choosing method (113400000 microseconds, range [400,1000] ms)
task_hyper_113400000_longs =  [405000, 420000, 450000, 453600, 472500, 504000, 506250, 525000, 540000, 567000, 590625,
                               600000, 630000, 648000, 675000, 700000, 708750, 756000, 787500, 810000, 840000, 900000,
                               907200, 945000]


# generate a taskset with uniform distribution between two periods in milliseconds (like Buttazzo method)
def create_random_taskset_between_two_periods (num_tasks, low, high, utilization):

    taskset = []
    periods = []
    # choosing periods
    for i in range (num_tasks):
        periods.append(randint(low,high) * 1000)
    periods.sort()
    for i in range (num_tasks):
        taskset.append ([(num_tasks - i), periods[i], periods[i], i+1, 0])
    # use UUnifast for utilization of tasks
    utilization_context_switch, utilization_clock, utilization_support_function = UUnifast(taskset, utilization)
    return taskset, utilization_context_switch, utilization_clock, utilization_support_function


# generate a taskset with uniform distribution between two periods in milliseconds (like Buttazzo method)
def create_random_taskset_between_two_periods_no_repetition (num_tasks, low, high, utilization):

    taskset = []
    periods = []
    # choosing periods
    i = 0
    while i < num_tasks:
        rand = randint(low, high) * 1000
        if rand not in periods:
            periods.append(rand)
            i = i+1
    periods.sort()
    for i in range (num_tasks):
        taskset.append ([(num_tasks - i), periods[i], periods[i], i+1, 0])
    # use UUnifast for utilization of tasks
    utilization_context_switch, utilization_clock, utilization_support_function = UUnifast(taskset, utilization)
    return taskset, utilization_context_switch, utilization_clock, utilization_support_function


# generate a taskset with hyperperiod choosing method (113400 milliseconds [10,100]) and choosing the armonicity grade
def create_taskset_hyper_113400000_10_100(num_tasks, utilization, min_armonicity_grade, max_armonicity_grade):

    taskset = []
    periods = []
    n_task_armonic = -1
    # choosing periods
    while n_task_armonic < min_armonicity_grade or n_task_armonic > max_armonicity_grade:
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
    # use UUnifast for utilization of tasks
    utilization_context_switch, utilization_clock, utilization_support_function = UUnifast(taskset, utilization)
    return taskset, utilization_context_switch, utilization_clock, utilization_support_function


# generate a taskset with hyperperiod choosing method (113400 milliseconds [10,200] and longs) and choosing the
# armonicity grade
def create_taskset_hyper_113400000_10_200_with_some_long (num_tasks, utilization, min_armonicity_grade, max_armonicity_grade):

    taskset = []
    periods = []
    # choosing periods
    n_task_armonic = -1
    while n_task_armonic < min_armonicity_grade or n_task_armonic > max_armonicity_grade:
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
    # use UUnifast for utilization of tasks
    utilization_context_switch, utilization_clock, utilization_support_function = UUnifast(taskset, utilization)
    return taskset, utilization_context_switch, utilization_clock, utilization_support_function


# generate a taskset  with full harmonic periods
def create_taskset_full_harmonic(utilization, periods, counter):

    taskset = []
    for i in range(20):
        taskset.append([(20 - i), periods[counter][i], periods[counter][i], i + 1, 0])
    # use UUnifast for utilization of tasks
    utilization_context_switch, utilization_clock, utilization_support_function = UUnifast(taskset, utilization)
    return taskset, utilization_context_switch, utilization_clock, utilization_support_function


# generate a taskset with an high degree of harmonicity
def create_taskset_semi_harmonic(utilization, periods, counter):

    taskset = []
    for i in range(20):
        taskset.append([(20 - i), periods[counter][i], periods[counter][i], i + 1, 0])
    # use UUnifast for utilization of tasks
    utilization_context_switch, utilization_clock, utilization_support_function = UUnifast(taskset, utilization)
    return taskset, utilization_context_switch, utilization_clock, utilization_support_function


# generate a taskset with log uniform distribution between two periods in milliseconds
def create_taskset_log_uniform(low, high, size, utilization):

    taskset = []
    # choosing periods
    periods = np.exp(np.random.uniform(math.log(low), math.log(high), size))
    periods = [x * 1000 for x in sorted(np.array(periods, dtype=int))]
    for i in range (size):
        taskset.append([(size - i), periods[i], periods[i], i + 1, 0])
    # use UUnifast for utilization of tasks
    utilization_context_switch, utilization_clock, utilization_support_function = UUnifast(taskset, utilization)
    return taskset, utilization_context_switch, utilization_clock, utilization_support_function