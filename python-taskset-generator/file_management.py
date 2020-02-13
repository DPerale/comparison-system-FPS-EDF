# File creator
def create_file(name, first_row):

    file = open (name, 'w')
    file.write (first_row + "\n")
    file.close()


# Taskset generator csv file
def register_to_file(taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM_miss, EDF_schedulable,
                     FPS_schedulable, EDF_response_time, FPS_response_time, FPS_deadline_miss_task,
                     utilization_context_switch, utilization_clock, utilization_support_function, hyperperiod, name):

    tasksets_file = open(name, 'a')
    tasksets_file.write(str(utilization)+";"+str(EDF_busy_period)+";"+str(FPS_busy_period)+";"+str(EDF_first_DM_miss)+
                        ";"+str(EDF_schedulable)+";"+str(FPS_schedulable)+";"+str(hyperperiod)+";")
    for i in range(len(taskset)):
        tasksets_file.write(str(taskset[i][0])+","+str(taskset[i][1])+","+str(taskset[i][2])+","+str(taskset[i][3])+
                        ","+str(taskset[i][4])+","+str(EDF_response_time[i])+","+str(FPS_response_time[i])+","+
                        str(FPS_deadline_miss_task[i])+","+str(utilization_context_switch[i])+","+
                        str(utilization_clock[i])+","+str(utilization_support_function[i])+";")
    tasksets_file.write("\n")
    tasksets_file.close()


# MAST EDF file creation
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


# MAST FPS file creation
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