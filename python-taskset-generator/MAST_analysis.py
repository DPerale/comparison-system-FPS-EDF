from file_management import create_MAST_input_file_EDF, create_MAST_input_file_FPS
from subprocess import Popen, PIPE

# save output from MAST for the EDF analysis
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


# save output from MAST for the FPS analysis
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