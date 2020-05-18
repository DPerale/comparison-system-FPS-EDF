from random import random, randint, choice, choices, sample
import numpy as np

# UUnifast algorithm
def UUnifast (taskset, utilization):

    utilization_context_switch = []
    utilization_clock = []
    utilization_support_function = []

    sumU = utilization

    # # Overheads calculation
    # # Utilization of context switch overhead
    # for i in range (len(taskset)):
    #     sumU = sumU - (12.46 / taskset[i][2])
    #     utilization_context_switch.append((12.46 / taskset[i][2]))
    # # Utilization of clock on wakeup tasks
    # for i in range (len(taskset)):
    #     sumU = sumU - (7.2 / taskset[i][2])
    #     utilization_clock.append((7.2 / taskset[i][2]))
    # # Utilization of overhead for support functions in task
    # for i in range (len(taskset)):
    #     sumU = sumU - (9.92 / taskset[i][2])
    #     utilization_support_function.append((9.92 / taskset[i][2]))

    # Overheads calculation
    # Utilization of context switch overhead
    for i in range (len(taskset)):
        sumU = sumU - (0 / taskset[i][2])
        utilization_context_switch.append((0 / taskset[i][2]))
    # Utilization of clock on wakeup tasks
    for i in range (len(taskset)):
        sumU = sumU - (0 / taskset[i][2])
        utilization_clock.append((0 / taskset[i][2]))
    # Utilization of overhead for support functions in task
    for i in range (len(taskset)):
        sumU = sumU - (0 / taskset[i][2])
        utilization_support_function.append((0 / taskset[i][2]))

    # Utilization of task calculation
    for i in range (1,len(taskset)):
        nextSumU = sumU * pow(random(), (1 / (len(taskset)-i)))
        while (sumU - nextSumU) >= 1 or (sumU - nextSumU) == 0:
            nextSumU = sumU * pow(random(), (1 / (len(taskset)-i)))
        taskset[i-1][4] = int((sumU - nextSumU) * taskset[i-1][2])
        sumU = nextSumU
    taskset[len(taskset)-1][4] = int(sumU * taskset[len(taskset)-1][2])
    return utilization_context_switch, utilization_clock, utilization_support_function


# hyperperiod calculation of taskset
def calculate_hyperperiod (taskset):

    periods = []
    for i in range (len(taskset)):
        periods.append(taskset[i][2])
    lcm = np.lcm.reduce(periods)
    return lcm


# generate 10000 set of full harmonic periods
def full_harmonic_periods_generator ():

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
        taskset_periods[i] = sorted([j * 1000 for j in taskset_periods[i]])
    return taskset_periods


# say if a number is prime or not
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


# generate 1000 set of highly harmonic periods
def semi_harmonic_periods_generator():

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
    return taskset_periods