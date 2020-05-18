import os
import csv


# import a taskset from the csv file made with python-taskset-generator
def import_taskset(taskset, i, name):

    with open('../taskset-generated/' + str(name)) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=';')
        row_number = 0
        for row in csv_reader:
            print(row)
            if row_number == i:
                utilization = row[0]
                EDF_busy_period = row[1]
                FPS_busy_period = row[2]
                EDF_first_DM = row[3]
                EDF_schedulable = row[4]
                FPS_schedulable = row[5]
                hyperperiod = row[6]
                for task in range (len(row)-8):
                    string_task = row[task+7].split(",")
                    task = [string_task[0],
                            string_task[1],
                            string_task[2],
                            string_task[3],
                            string_task[4],
                            str((float(string_task[8]) + float(string_task[9])))]
                            #str((float(string_task[8])+float(string_task[9])+float(string_task[10])))]
                    taskset.append (task)
                return taskset, utilization, EDF_busy_period, FPS_busy_period, EDF_first_DM, EDF_schedulable, FPS_schedulable, hyperperiod
            row_number = row_number + 1


# make taskset adb file for Ravenscar
def make_adb_file (taskset, hyperPeriod):

    file_adb = open("../edf-ravenscar-arm/src/cyclic_tasks.adb", "w")
    file_adb.write("with Ada.Real_Time; use Ada.Real_Time;\n")
    file_adb.write("with System_Time;\n")
    file_adb.write("with System.Task_Primitives.Operations;\n")
    file_adb.write("with System.BB.Time;\n")
    file_adb.write("with System.BB.Threads;\n")
    file_adb.write("with System.BB.Threads.Queues;\n")
    file_adb.write("with Log_Reporter_Task;\n")
    file_adb.write("\n")
    file_adb.write("package body Cyclic_Tasks is\n")
    file_adb.write("\n")
    file_adb.write("   task body Cyclic is\n")
    file_adb.write("      Task_Static_Offset : constant Time_Span :=\n")
    file_adb.write("               Ada.Real_Time.Microseconds (Offset);\n")
    file_adb.write("\n")
    file_adb.write("      Next_Period : Ada.Real_Time.Time := System_Time.System_Start_Time\n")
    file_adb.write("            + System_Time.Task_Activation_Delay + Task_Static_Offset;\n")
    file_adb.write("\n")
    file_adb.write("      Period_To_Add : constant Ada.Real_Time.Time_Span :=\n")
    file_adb.write("               Ada.Real_Time.Microseconds (Period);\n")
    file_adb.write("\n")
    file_adb.write("      procedure Job (Times : Integer);\n")
    file_adb.write("      procedure Job (Times : Integer) is\n")
    file_adb.write("         Num : Integer := 0;\n")
    file_adb.write("      begin\n")
    file_adb.write("         for I in 1 .. Times loop\n")
    file_adb.write("            Num := Num + I;\n")
    file_adb.write("         end loop;\n")
    file_adb.write("      end Job;\n")
    file_adb.write("      function Time_Conversion (Time_in  : Ada.Real_Time.Time)\n")
    file_adb.write("                                return System.BB.Time.Time_Span;\n")
    file_adb.write("      function Time_Conversion (Time_in  : Ada.Real_Time.Time)\n")
    file_adb.write("                                return System.BB.Time.Time_Span is\n")
    file_adb.write("         Time_in_to_Time_Span : Ada.Real_Time.Time_Span;\n")
    file_adb.write("         Time_out : System.BB.Time.Time_Span;\n")
    file_adb.write("      begin\n")
    file_adb.write("         Time_in_to_Time_Span := Time_in - Ada.Real_Time.Time_First;\n")
    file_adb.write("         Time_out := System.BB.Time.To_Time_Span\n")
    file_adb.write("           (Ada.Real_Time.To_Duration (Time_in_to_Time_Span));\n")
    file_adb.write("         return Time_out;\n")
    file_adb.write("      end Time_Conversion;\n")
    file_adb.write("\n")
    file_adb.write("      My_Workload : constant Integer := Workload;\n")
    file_adb.write("      Synchronization : Ada.Real_Time.Time_Span;\n")
    file_adb.write("\n")
    file_adb.write("   begin\n")
    file_adb.write("      Synchronization := Next_Period - Ada.Real_Time.Time_First;\n")
    file_adb.write("      Synchronization := (Synchronization / 180000) * 180000;\n")
    file_adb.write("      Synchronization := Synchronization - Ada.Real_Time.Microseconds (73);\n")
    file_adb.write("      Next_Period := Ada.Real_Time.Time_First + Synchronization;\n")
    file_adb.write("      System.Task_Primitives.Operations.Set_Period\n")
    file_adb.write("         (System.Task_Primitives.Operations.Self,\n")
    file_adb.write("         System.BB.Time.Microseconds (Period));\n")
    file_adb.write("      System.Task_Primitives.Operations.Set_Starting_Time\n")
    file_adb.write("        (System.Task_Primitives.Operations.Self,\n")
    file_adb.write("          Time_Conversion (Next_Period));\n")
    file_adb.write("      System.Task_Primitives.Operations.Set_Relative_Deadline\n")
    file_adb.write("         (System.Task_Primitives.Operations.Self,\n")
    file_adb.write("          System.BB.Time.Microseconds (Deadline), False);\n")
    file_adb.write("      System.BB.Threads.Set_Fake_Number_ID (T_Num);\n")
    file_adb.write("      System.BB.Threads.Queues.Initialize_Log_Table (T_Num);\n")
    file_adb.write("\n")
    file_adb.write("      loop\n")
    file_adb.write("         delay until Next_Period;\n")
    file_adb.write("\n")
    file_adb.write("         Job (My_Workload);\n")
    file_adb.write("\n")
    file_adb.write("         Next_Period := Next_Period + Period_To_Add;\n")
    file_adb.write("      end loop;\n")
    file_adb.write("   end Cyclic;\n")
    file_adb.write("\n")
    file_adb.write("   procedure Init is\n")
    file_adb.write("   begin\n")
    file_adb.write("      System.Task_Primitives.Operations.Set_Relative_Deadline\n")
    file_adb.write("        (System.Task_Primitives.Operations.Self,\n")
    file_adb.write("          System.BB.Time.Milliseconds (Integer'Last), False);\n")
    file_adb.write("      loop\n")
    file_adb.write("         null;\n")
    file_adb.write("      end loop;\n")
    file_adb.write("   end Init;\n")
    file_adb.write("\n")
    file_adb.write("   P1 : Log_Reporter_Task.Log_Reporter (240, -" + str(1)+ ", " + str(int(float(hyperPeriod)/1000)) + ", 0); -- milliseconds\n")
    for task in range (len(taskset)):
        work = int((float(taskset[task][4])-1.62)*180/17)
        file_adb.write("   C"+str(task+1)+" : Cyclic ("+str(len(taskset)-task)+", "
                                                        +str(taskset[task][1])+", "
                                                        +str(taskset[task][2])+", "
                                                        +str(task+1)+", "
                                                        +str(work)+", 0);\n")
    file_adb.write ("end Cyclic_Tasks;")
    file_adb.close()
    os.system("cp ../edf-ravenscar-arm/src/cyclic_tasks.adb ../fps-ravenscar-arm/src/cyclic_tasks.adb")


# save the data into a csv file
def save_data (taskset, EDF_data, FPS_data, name, unique_name, hyperperiod):

    with open('../taskset-experiments/'+str(name)+'_'+str(unique_name)+'.csv', mode='w') as csv_to_write:
        csv_writer = csv.writer(csv_to_write, delimiter=';')
        csv_writer.writerow(
            ['ID', 'Priority', 'Period', 'Deadline', 'WCET', 'FPS Deadline Miss', 'FPS Regular Completions', 'FPS Preemptions', 'Less', 'EDF Deadline Miss', 'EDF Regular Completions', 'EDF Preemptions', 'Utilization by work', 'Utilization by calculable overheads', '', 'FPS Min Response Jitter', 'FPS Max Response Jitter', 'FPS Min Release Jitter', 'FPS Max Release Jitter', 'FPS Avarage Response Jitter', 'EDF Min Response Jitter', 'EDF Max Response Jitter', 'EDF Min Release Jitter', 'EDF Max Release Jitter', 'EDF Avarage Response Jitter'])
        sum_FPS_preemptions = 0
        sum_EDF_preemptions = 0
        sum_utilization = 0
        sum_utilization_by_overheads = 0
        for i in range(len(taskset)):
            sum_FPS_preemptions = sum_FPS_preemptions + int(FPS_data[i][2])
            sum_EDF_preemptions = sum_EDF_preemptions + int(EDF_data[i][2])
            sum_utilization = sum_utilization + float(taskset[i][4]) / float(taskset[i][1])
            sum_utilization_by_overheads = sum_utilization_by_overheads + float (taskset[i][5])
            csv_writer.writerow([taskset[i][3], taskset[i][0], taskset[i][1], taskset[i][2], taskset[i][4],
                                 str(int(FPS_data[i][0])), str(int(FPS_data[i][1])), str(int(FPS_data[i][2])),
                                 str(int(FPS_data[i][2])-int(EDF_data[i][2])),
                                 str(EDF_data[i][0]), str(EDF_data[i][1]),str(EDF_data[i][2]),
                                 str(float(taskset[i][4])/float(taskset[i][1])),
                                 str(taskset[i][5]), '',
                                 str(int(FPS_data[i][3])), str(int(FPS_data[i][4])), str(int(FPS_data[i][5])),
                                 str(int(FPS_data[i][6])), str(int(FPS_data[i][7])),
                                 str(int(EDF_data[i][3])), str(int(EDF_data[i][4])), str(int(EDF_data[i][5])),
                                 str(int(EDF_data[i][6])), str(int(EDF_data[i][7]))
                                 ])
        csv_writer.writerow(['', '', hyperperiod, '', '', '', '', str(sum_FPS_preemptions), '', '', '',
                             str(sum_EDF_preemptions), str(sum_utilization), str(sum_utilization_by_overheads),
                             str(sum_utilization+sum_utilization_by_overheads)])
        csv_writer.writerow(
            ['', '', '', '', '', '', '', str(float((sum_FPS_preemptions - sum_EDF_preemptions)/sum_FPS_preemptions)),
             '', '', '', '', ''])