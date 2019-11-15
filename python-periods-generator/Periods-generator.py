# task_periods_for_non_harmonic = [   10000, # Short (0,28)
#                                     10584,
#                                     11340,
#                                     12150,
#                                     13230,
#                                     14112,
#                                     15120,
#                                     16000,
#                                     17280,
#                                     18375,
#                                     21168,
#                                     22680,
#                                     24192,
#                                     26250,
#                                     28224,
#                                     31500,
#                                     33750,
#                                     36288,
#                                     39375,
#                                     42000,
#                                     45000,
#                                     48000,
#                                     52500,
#                                     55125,
#                                     59535,
#                                     61250,
#                                     70875,
#                                     77760,
#                                     79380,
#                                     189000, # Medium (29,57)
#                                     190512,
#                                     194400,
#                                     198450,
#                                     201600,
#                                     202500,
#                                     211680,
#                                     212625,
#                                     217728,
#                                     220500,
#                                     226800,
#                                     236250,
#                                     238140,
#                                     240000,
#                                     243000,
#                                     252000,
#                                     254016,
#                                     264600,
#                                     272160,
#                                     280000,
#                                     282240,
#                                     294000,
#                                     297675,
#                                     302400,
#                                     303750,
#                                     317520,
#                                     330750,
#                                     340200,
#                                     352800,
#                                     420000, # Long (58,86)
#                                     423360,
#                                     425250,
#                                     432000,
#                                     441000,
#                                     453600,
#                                     470400,
#                                     472500,
#                                     476280,
#                                     486000,
#                                     490000,
#                                     496125,
#                                     504000,
#                                     508032,
#                                     529200,
#                                     540000,
#                                     544320,
#                                     551250,
#                                     560000,
#                                     567000,
#                                     588000,
#                                     595350,
#                                     604800,
#                                     607500,
#                                     630000,
#                                     635040,
#                                     648000,
#                                     661500,
#                                     680400    ]
#
# hyperperiod = 952560000
#
# n2 = 6
# n3 = 1
# n5 = 7
# n7 = 1
#
# numbers = []
#
# x = 0
# short = 0
# medium = 0
# long = 0
#
# for i in range(n2+1):
#     for j in range(n3+1):
#         for l in range(n5+1):
#             for m in range(n7+1):
#                 numbers.append(((2**i)*(3**j)*(5**l)*(7**m)))
#                 if ((2**i)*(3**j)*(5**l)*(7**m)) > 9999 and ((2**i)*(3**j)*(5**l)*(7**m)) < 700000:
#                     x = x+1
#                     if ((2 ** i) * (3 ** j) * (5 ** l) * (7 ** m)) <= 236000 :
#                         short = short + 1
#                     if ((2 ** i) * (3 ** j) * (5 ** l) * (7 ** m)) > 236000 and ((2 ** i) * (3 ** j) * (5 ** l) * (7 ** m)) <= 473000:
#                         medium = medium + 1
#                     if ((2 ** i) * (3 ** j) * (5 ** l) * (7 ** m)) > 473000:
#                         long = long + 1
# numbers.sort()
# print(numbers)
# print(len(numbers))
# print(x)
# print(short)
# print(medium)
# print(long)

# c(10000,
#                      28224,
#                      42000,
#                      55125,
#                      59535,
#                      79380,
#                      86400,
#                      95256,
#                      101250,
#                      122500,
#                      140000,
#                      147000,
#                      151200,
#                      158760,
#                      183750,
#                      189000,
#                      194400,
#                      201600,
#                      211680,
#                      212625,
#                      217728,
#                      220500,
#                      236250,
#                      243000,
#                      259200,
#                      264600,
#                      270000,
#                      272160,
#                      282240,
#                      294000,
#                      302400,
#                      303750,
#                      340200,
#                      352800,
#                      381024,
#                      388800,
#                      396900,
#                      405000,
#                      420000,
#                      423360,
#                      425250,
#                      432000,
#                      441000,
#                      453600,
#                      470400,
#                      472500,
#                      476280,
#                      486000,
#                      490000,
#                      496125,
#                      504000,
#                      508032,
#                      529200,
#                      540000,
#                      544320,
#                      551250,
#                      567000,
#                      588000,
#                      595350,
#                      604800,
#                      607500,
#                      630000,
#                      635040,
#                      648000,
#                      661500,
#                      680400)

######  FULL HARMONIC

# import random
# from random import randint
#
# taskset = []
# for i in range (10000):
#     taskset.append([])
# for l in range (500):
#     if l<200:
#         min_int = max_int = int(l/50) + 2
#         print(min_int)
#     else:
#         min_int = 2
#         max_int = 5
#
#     for i in range (10,30):
#         n = i
#         t = 1
#         taskset[l*20 + i-10].append(n)
#         while (t < 20 and n <= 500):
#             if (l >= 200):
#                 temp = n*randint(min_int,max_int)
#                 if(temp != taskset[l*20+i-10][t-1] and temp <= 1000):
#                     n = temp
#                     taskset[l*20 + i-10].append(n)
#                     t = t + 1
#             else:
#                 n = n * randint(min_int, max_int)
#                 if(n <= 1000):
#                     taskset[l * 20 + i - 10].append(n)
#                     t = t + 1
#
#         if t < 19:
#             t2 = t
#             while (t < 20):
#                 temp = random.choice(taskset[l*20 + i-10][0:t2])
#                 taskset[l*20 + i-10].append(temp)
#                 t = t + 1
#
# for i in range(10000):
#     taskset[i] = sorted([j * 1000 for j in taskset[i]])
#     #print(taskset[i])
#
#
#
# def isPrime(n):
#     if (n <= 1):
#         return False
#     if (n <= 3):
#         return True
#     if (n % 2 == 0 or n % 3 == 0):
#         return False
#     i = 5
#     while (i * i <= n):
#         if (n % i == 0 or n % (i + 2) == 0):
#             return False
#         i = i + 6
#     return True
#
# from math import gcd
# def calc_lcm(a):
#     lcm = a[0]
#     for i in a[1:]:
#         lcm = int(lcm*i/gcd(lcm, i))
#     return lcm



####### GOOD HARMONIC


# reintroduction = True
# taskset = []
# for i in range (500):
#     taskset.append([])
# for z in range (25):
#     for i in range (10,30):
#         n = i
#         t = 0
#         possibleChoiches = []
#         possibleChoiches.append(n)
#         while (n < 1000):
#             n = n + i
#             possibleChoiches.append(n)
#         n2 = 4
#         n3 = 1
#         n5 = 2
#         n7 = 1
#         nmin = 0
#         min_i = i
#         if (isPrime(i)):
#             nmin = 1
#         else:
#             if (i == 22 or i == 26):
#                 nmin = 1
#                 min_i = int(i/2)
#             else:
#                 if (i == 27 or i == 18):
#                     n2 = 5
#                     n3 = 3
#                     n5 = 2
#                 else:
#                     n2 = 6
#                     n3 = 2
#                     n5 = 2
#
#         numbers = []
#
#         for f in range((n2+1)):
#             for j in range((n3+1)):
#                 for l in range((n5+1)):
#                     for m in range((n7+1)):
#                         for o in range((nmin+1)):
#                             if ((2 ** f) * (3 ** j) * (5 ** l) * (7 ** m) * (min_i ** o)) >= 10 and ((2 ** f) * (3 ** j) * (5 ** l) * (7 ** m) * (min_i ** o)) < 1000:
#                                 numbers.append(((2**f)*(3**j)*(5**l)*(7**m)*(min_i ** o)))
#
#         common = sorted(list(set(possibleChoiches).intersection(numbers)))
#
#         if (len(common) >= 20):
#             if reintroduction :
#                 taskset[(z * 20) + (i - 10)] = sorted(random.choices(common, k=20))
#             else:
#                 taskset[(z*20)+(i-10)] = sorted(random.sample(common, 20))
#             t = 20
#         else:
#             taskset[(z*20)+(i-10)] = common
#             t = len(common)
#
#         if (t < 20):
#             t2 = t
#             while (t < 20):
#                 temp = random.choice(taskset[(z*20)+(i-10)][0:t2])
#                 taskset[(z*20)+(i-10)].append(temp)
#                 t = t + 1
#
#         calc_lcm([int(g) for g in taskset[(z*20)+(i-10)]])
#
# for i in range(500):
#     print(taskset[i])

import numpy as np
import math

def loguniform(low, high, size):
    return np.exp(np.random.uniform(math.log(low), math.log(high), size))

def calculate_hyperperiod (periods):
    lcm = np.lcm.reduce(periods)

    return lcm
for l in range (100):
    ciao = loguniform(10, 101, 20)
    for i in range(20):
        ciao[i] = int(math.floor(ciao[i]/1)*1)
    ciao2 = np.array(ciao, dtype=int)
    print(calculate_hyperperiod(ciao2))