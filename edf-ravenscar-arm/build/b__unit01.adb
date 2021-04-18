pragma Warnings (Off);
pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b__unit01.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b__unit01.adb");
pragma Suppress (Overflow_Check);

package body ada_main is

   E047 : Short_Integer; pragma Import (Ada, E047, "system__soft_links_E");
   E045 : Short_Integer; pragma Import (Ada, E045, "system__exception_table_E");
   E052 : Short_Integer; pragma Import (Ada, E052, "ada__tags_E");
   E093 : Short_Integer; pragma Import (Ada, E093, "system__bb__timing_events_E");
   E008 : Short_Integer; pragma Import (Ada, E008, "ada__real_time_E");
   E125 : Short_Integer; pragma Import (Ada, E125, "system__tasking__restricted__stages_E");
   E127 : Short_Integer; pragma Import (Ada, E127, "system_time_E");
   E123 : Short_Integer; pragma Import (Ada, E123, "log_reporter_task_E");
   E005 : Short_Integer; pragma Import (Ada, E005, "cyclic_tasks_E");

   Sec_Default_Sized_Stacks : array (1 .. 6) of aliased System.Secondary_Stack.SS_Stack (System.Parameters.Runtime_Default_Sec_Stack_Size);

   Local_Priority_Specific_Dispatching : constant String := "";
   Local_Interrupt_States : constant String := "";

   Is_Elaborated : Boolean := False;

   procedure adafinal is
      procedure s_stalib_adafinal;
      pragma Import (C, s_stalib_adafinal, "system__standard_library__adafinal");

      procedure Runtime_Finalize;
      pragma Import (C, Runtime_Finalize, "__gnat_runtime_finalize");

   begin
      if not Is_Elaborated then
         return;
      end if;
      Is_Elaborated := False;
      Runtime_Finalize;
      s_stalib_adafinal;
   end adafinal;

   procedure adainit is
      Main_Priority : Integer;
      pragma Import (C, Main_Priority, "__gl_main_priority");
      Time_Slice_Value : Integer;
      pragma Import (C, Time_Slice_Value, "__gl_time_slice_val");
      WC_Encoding : Character;
      pragma Import (C, WC_Encoding, "__gl_wc_encoding");
      Locking_Policy : Character;
      pragma Import (C, Locking_Policy, "__gl_locking_policy");
      Queuing_Policy : Character;
      pragma Import (C, Queuing_Policy, "__gl_queuing_policy");
      Task_Dispatching_Policy : Character;
      pragma Import (C, Task_Dispatching_Policy, "__gl_task_dispatching_policy");
      Priority_Specific_Dispatching : System.Address;
      pragma Import (C, Priority_Specific_Dispatching, "__gl_priority_specific_dispatching");
      Num_Specific_Dispatching : Integer;
      pragma Import (C, Num_Specific_Dispatching, "__gl_num_specific_dispatching");
      Main_CPU : Integer;
      pragma Import (C, Main_CPU, "__gl_main_cpu");
      Interrupt_States : System.Address;
      pragma Import (C, Interrupt_States, "__gl_interrupt_states");
      Num_Interrupt_States : Integer;
      pragma Import (C, Num_Interrupt_States, "__gl_num_interrupt_states");
      Unreserve_All_Interrupts : Integer;
      pragma Import (C, Unreserve_All_Interrupts, "__gl_unreserve_all_interrupts");
      Detect_Blocking : Integer;
      pragma Import (C, Detect_Blocking, "__gl_detect_blocking");
      Default_Stack_Size : Integer;
      pragma Import (C, Default_Stack_Size, "__gl_default_stack_size");
      Default_Secondary_Stack_Size : System.Parameters.Size_Type;
      pragma Import (C, Default_Secondary_Stack_Size, "__gnat_default_ss_size");
      Leap_Seconds_Support : Integer;
      pragma Import (C, Leap_Seconds_Support, "__gl_leap_seconds_support");
      Bind_Env_Addr : System.Address;
      pragma Import (C, Bind_Env_Addr, "__gl_bind_env_addr");

      procedure Runtime_Initialize (Install_Handler : Integer);
      pragma Import (C, Runtime_Initialize, "__gnat_runtime_initialize");
      Binder_Sec_Stacks_Count : Natural;
      pragma Import (Ada, Binder_Sec_Stacks_Count, "__gnat_binder_ss_count");
      Default_Sized_SS_Pool : System.Address;
      pragma Import (Ada, Default_Sized_SS_Pool, "__gnat_default_ss_pool");

   begin
      if Is_Elaborated then
         return;
      end if;
      Is_Elaborated := True;
      Main_Priority := -1;
      Time_Slice_Value := 0;
      WC_Encoding := 'b';
      Locking_Policy := 'C';
      Queuing_Policy := ' ';
      Task_Dispatching_Policy := 'F';
      Priority_Specific_Dispatching :=
        Local_Priority_Specific_Dispatching'Address;
      Num_Specific_Dispatching := 0;
      Main_CPU := -1;
      Interrupt_States := Local_Interrupt_States'Address;
      Num_Interrupt_States := 0;
      Unreserve_All_Interrupts := 0;
      Detect_Blocking := 1;
      Default_Stack_Size := -1;
      Leap_Seconds_Support := 0;

      ada_main'Elab_Body;
      Default_Secondary_Stack_Size := System.Parameters.Runtime_Default_Sec_Stack_Size;
      Binder_Sec_Stacks_Count := 6;
      Default_Sized_SS_Pool := Sec_Default_Sized_Stacks'Address;

      Runtime_Initialize (1);

      System.Soft_Links'Elab_Spec;
      System.Exception_Table'Elab_Body;
      E045 := E045 + 1;
      Ada.Tags'Elab_Body;
      E052 := E052 + 1;
      System.Bb.Timing_Events'Elab_Spec;
      System.Bb.Timing_Events'Elab_Body;
      E093 := E093 + 1;
      E047 := E047 + 1;
      Ada.Real_Time'Elab_Body;
      E008 := E008 + 1;
      System.Tasking.Restricted.Stages'Elab_Body;
      E125 := E125 + 1;
      System_Time'Elab_Spec;
      E127 := E127 + 1;
      Log_Reporter_Task'Elab_Body;
      E123 := E123 + 1;
      Cyclic_Tasks'Elab_Body;
      E005 := E005 + 1;
   end adainit;

   procedure Ada_Main_Program;
   pragma Import (Ada, Ada_Main_Program, "_ada_unit01");

   procedure main is
      procedure Initialize (Addr : System.Address);
      pragma Import (C, Initialize, "__gnat_initialize");

      procedure Finalize;
      pragma Import (C, Finalize, "__gnat_finalize");
      SEH : aliased array (1 .. 2) of Integer;

      Ensure_Reference : aliased System.Address := Ada_Main_Program_Name'Address;
      pragma Volatile (Ensure_Reference);

   begin
      Initialize (SEH'Address);
      adainit;
      Ada_Main_Program;
      adafinal;
      Finalize;
   end;

--  BEGIN Object file/option list
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/system.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/s-bb.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/s-bbpara.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/s-multip.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/s-bbbosu.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/s-bbdead.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/s-bbtiev.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/s-bbthqu.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/s-bbprot.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/s-bbthre.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/s-bbinte.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/s-bbcppr.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/s-osinte.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/a-elchha.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/s-taspri.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/s-tasdeb.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/s-taskin.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/s-soflin.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/s-bbtime.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/s-mufalo.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/s-taprop.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/a-reatim.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/a-retide.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/s-tasres.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/s-tarest.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/system_time.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/log_reporter_task.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/cyclic_tasks.o
   --   /home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/unit01.o
   --   -L/home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/
   --   -L/home/aquox/Scrivania/comparison-system-FPS-EDF/edf-ravenscar-arm/build/
   --   -L/usr/local/gnat-arm/arm-eabi/lib/gnat/ravenscar-full-stm32f429disco/adalib/
   --   -static
   --   -lgnarl
   --   -lgnat
--  END Object file/option list   

end ada_main;
