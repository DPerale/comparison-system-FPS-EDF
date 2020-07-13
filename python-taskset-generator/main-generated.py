from file_management import create_file, register_to_file
from MAST_analysis import MAST_EDF_Analysis, MAST_FPS_Analysis
from taskset_generator import create_random_taskset_between_two_periods, \
    create_random_taskset_between_two_periods_no_repetition, create_taskset_hyper_113400000_10_100, \
    create_taskset_hyper_113400000_10_200_with_some_long, create_taskset_full_harmonic, create_taskset_semi_harmonic, \
    create_taskset_log_uniform
from support_functions import calculate_hyperperiod, full_harmonic_periods_generator, semi_harmonic_periods_generator


# taskset generated for experiments of Buttazzo method 1 and 2, with possible repetition of periods
def buttazzo_experiments_preemptions ():

    utilization = 0.9
    create_file("../taskset-generated/buttazzo_preemptions.csv", "utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i,utilization_clock, utilization_support_function_i")
    # Buttazzo method 1
    for i in range (2,11):
        for j in range(1000):
            taskset, utilization_context_switch, utilization_clock, utilization_support_function = \
                create_random_taskset_between_two_periods(i*2, 10, 100, utilization)
            EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
            FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
            register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss,
                             EDF_schedulable, FPS_schedulable, EDF_response_time, FPS_response_time,
                             FPS_deadline_miss_task, utilization_context_switch, utilization_clock,
                             utilization_support_function, 1000000, "../taskset-generated/buttazzo_preemptions.csv")
    # Buttazzo method 2
    for i in range (10):
        utilization = 0.5 + i*0.05
        for j in range(1000):
            taskset, utilization_context_switch, utilization_clock, utilization_support_function = \
                create_random_taskset_between_two_periods(10, 10, 100, utilization)
            EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
            FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
            register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss,
                             EDF_schedulable, FPS_schedulable, EDF_response_time, FPS_response_time,
                             FPS_deadline_miss_task, utilization_context_switch, utilization_clock,
                             utilization_support_function, 1000000, "../taskset-generated/buttazzo_preemptions.csv")


# taskset generated for experiments of of Buttazzo method 1 and 2, with no possible repetition of periods
def buttazzo_experiments_preemptions_no_repetition ():

    utilization = 0.9
    create_file("../taskset-generated/buttazzo_preemptions_no_repetition.csv", "utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i,utilization_clock, utilization_support_function_i")
    # Buttazzo method 1 no periods repetition
    for i in range (2,11):
        for j in range(500):
            print(j)
            taskset, utilization_context_switch, utilization_clock, utilization_support_function = \
                create_random_taskset_between_two_periods_no_repetition (i*2, 10, 100, utilization)
            EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
            FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
            register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss,
                             EDF_schedulable, FPS_schedulable, EDF_response_time, FPS_response_time,
                             FPS_deadline_miss_task, utilization_context_switch, utilization_clock,
                             utilization_support_function, 1000000,
                             "../taskset-generated/buttazzo_preemptions_no_repetition.csv")
    # Buttazzo method 2 no periods repetition
    for i in range (10):
        utilization = 0.5 + i*0.05
        for j in range(500):
            print(j)
            taskset, utilization_context_switch, utilization_clock, utilization_support_function = \
                create_random_taskset_between_two_periods_no_repetition (10, 10, 100, utilization)
            EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
            FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
            register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss,
                             EDF_schedulable, FPS_schedulable, EDF_response_time, FPS_response_time,
                             FPS_deadline_miss_task, utilization_context_switch, utilization_clock,
                             utilization_support_function, 1000000,
                             "../taskset-generated/buttazzo_preemptions_no_repetition.csv")


# taskset generated for experiments of choosing hyperperiod method [10,100]
def hyper_113400000_x_x_armonic_10_100():

    utilization = 0.9
    for l in range(3):
        min_armonicity_grade = 0
        max_armonicity_grade = 0
        if (l == 0):
            min_armonicity_grade = 0
            max_armonicity_grade = 2
        if (l == 1):
            min_armonicity_grade = 3
            max_armonicity_grade = 6
        if (l == 2):
            min_armonicity_grade = 7
            max_armonicity_grade = 20
        create_file(("../taskset-generated/hyper_113400000_" + str(min_armonicity_grade) + "_" +str(max_armonicity_grade) +"_armonic_10_100.csv"),
                "utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i,utilization_clock, utilization_support_function_i")
        for j in range(500):
            taskset, utilization_context_switch, utilization_clock, utilization_support_function = \
                create_taskset_hyper_113400000_10_100(20, utilization, min_armonicity_grade, max_armonicity_grade)
            hyperperiod = calculate_hyperperiod(taskset)
            EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
            FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
            register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable,
                             FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task,
                             utilization_context_switch, utilization_clock, utilization_support_function, hyperperiod,
                             "../taskset-generated/hyper_113400000_" + str(min_armonicity_grade) + "_" +
                             str(max_armonicity_grade) +"armonic_10_100.csv")


# taskset generated for experiments with choosing hyperperiod method [10,200] with some long periods
def hyper_113400000_x_x_armonic_10_200():

    utilization = 0.9
    for l in range(3):
        min_armonicity_grade = 0
        max_armonicity_grade = 0
        if (l == 0):
            min_armonicity_grade = 0
            max_armonicity_grade = 2
        if (l == 1):
            min_armonicity_grade = 3
            max_armonicity_grade = 6
        if (l == 2):
            min_armonicity_grade = 7
            max_armonicity_grade = 20
        create_file("../taskset-generated/hyper_113400000_"+ str(min_armonicity_grade) + "_" +str(max_armonicity_grade) +"_armonic_10_200.csv",
                    "utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i,utilization_clock, utilization_support_function_i")
        for j in range(500):
            print(j)
            taskset, utilization_context_switch, utilization_clock, utilization_support_function = \
                create_taskset_hyper_113400000_10_200_with_some_long (20, utilization, min_armonicity_grade, max_armonicity_grade)

            hyperperiod = calculate_hyperperiod(taskset)
            EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
            FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)


            register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable,
                             FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task,
                             utilization_context_switch, utilization_clock, utilization_support_function, hyperperiod,
                             "../taskset-generated/hyper_113400000_"+ str(min_armonicity_grade) + "_" +str(max_armonicity_grade) +"_armonic_10_200.csv")


# taskset generated for experiments with choosing hyperperiod method [10,200] with some long periods reproducing
# experiment of Buttazzo method 2
def hyper_113400000_10_200_with_some_long_U_60_70_80_90():

    create_file("../taskset-generated/hyper_113400000_10_200_with_some_long_U_60_70_80_90.csv",
                "utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i,utilization_clock, utilization_support_function_i")
    for i in range(4):
        utilization = 0.6 + (0.1 * i)
        for j in range(500):
            taskset, utilization_context_switch, utilization_clock, utilization_support_function = \
                create_taskset_hyper_113400000_10_200_with_some_long (20, utilization, 0, 20)
            hyperperiod = calculate_hyperperiod(taskset)
            EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
            FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
            register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable,
                             FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task,
                             utilization_context_switch, utilization_clock, utilization_support_function, hyperperiod,
                             "../taskset-generated/hyper_113400000_10_200_with_some_long_U_60_70_80_90.csv")


# taskset generated for experiments of full-harmonic
def full_harmonic():

    create_file("../taskset-generated/full_harmonic.csv",
                "utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i,utilization_clock, utilization_support_function_i")
    utilization = 0.9
    periods = full_harmonic_periods_generator()
    for i in range(10000):
        print(i)
        taskset, utilization_context_switch, utilization_clock, utilization_support_function = \
            create_taskset_full_harmonic(utilization, periods, i)
        hyperperiod = calculate_hyperperiod(taskset)
        EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
        FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
        register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable,
                         FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task,
                         utilization_context_switch, utilization_clock, utilization_support_function, hyperperiod,
                         "../taskset-generated/full_harmonic.csv")


# taskset generated for experiments of semi-harmonic
def semi_harmonic():

    create_file("../taskset-generated/semi_harmonic.csv",
                "utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i,utilization_clock, utilization_support_function_i")
    utilization = 0.9
    periods = semi_harmonic_periods_generator()
    for i in range(1000):
        print(i)
        taskset, utilization_context_switch, utilization_clock, utilization_support_function = \
            create_taskset_semi_harmonic(utilization, periods, i)
        hyperperiod = calculate_hyperperiod(taskset)
        EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
        FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
        register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable,
                         FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task,
                         utilization_context_switch, utilization_clock, utilization_support_function, hyperperiod,
                         "../taskset-generated/semi_harmonic.csv")


# taskset generated for experiments with log uniform distribution
def U_90_log_uniform():

    create_file("../taskset-generated/U_90_log_uniform.csv",
                "utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i,utilization_clock, utilization_support_function_i")
    utilization = 0.9
    for j in range(1000):
        print(j)
        taskset, utilization_context_switch, utilization_clock, utilization_support_function = \
            create_taskset_log_uniform(10, 100, 20, utilization)
        hyperperiod = 1000000
        EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
        FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
        register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable,
                         FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task,
                         utilization_context_switch, utilization_clock, utilization_support_function, hyperperiod,
                         "../taskset-generated/U_90_log_uniform.csv")


# taskset generated for experiments with utilization greater than 1
def U_100_hyper_113400000_10_100():

    utilization = 1.00
    create_file("../taskset-generated/U_100_hyper_113400000_10_100.csv",
                "utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i,utilization_clock, utilization_support_function_i")

    for j in range(500):
        print(j)
        taskset, utilization_context_switch, utilization_clock, utilization_support_function = \
            create_taskset_hyper_113400000_10_100(20, utilization, 0, 20)
        hyperperiod = calculate_hyperperiod(taskset)
        EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
        FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
        register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable,
                         FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task,
                         utilization_context_switch, utilization_clock, utilization_support_function, hyperperiod,
                         "../taskset-generated/U_100_hyper_113400000_10_100.csv")


def buttazzo_experiments_preemptions_over ():

    # Buttazzo method 2
    create_file("../taskset-generated/buttazzo_preemptions_over2.csv",
                "utilization;EDF_busy_period;FPS_busy_period;EDF_first_DM_miss;EDF_schedulable;FPS_schedulable;hyperperiod;Priority_i,Deadline_i,Period_i,ID_i,WCET_i,EDF_response_time_i,FPS_response_time_i,FPS_deadline_miss_task_i,utilization_context_switch_i,utilization_clock, utilization_support_function_i")

    for i in range (1):
        utilization = 0.99
        for j in range(1000):
            print(j)
            taskset, utilization_context_switch, utilization_clock, utilization_support_function = \
                create_random_taskset_between_two_periods(10, 10, 100, utilization)
            EDF_busy_period, EDF_first_DM_miss, EDF_schedulable, EDF_response_time = MAST_EDF_Analysis(taskset)
            FPS_busy_period, FPS_schedulable, FPS_response_time, FPS_deadline_miss_task = MAST_FPS_Analysis(taskset)
            register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss,
                             EDF_schedulable, FPS_schedulable, EDF_response_time, FPS_response_time,
                             FPS_deadline_miss_task, utilization_context_switch, utilization_clock,
                             utilization_support_function, 1000000, "../taskset-generated/buttazzo_preemptions_over2.csv")


# use a function here
# U_100_hyper_113400000_10_100()
buttazzo_experiments_preemptions_over ()