pragma Warnings (Off);
pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b__gee.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b__gee.adb");
pragma Suppress (Overflow_Check);

with System.Restrictions;

package body ada_main is

   E076 : Short_Integer; pragma Import (Ada, E076, "ada__tags_E");
   E051 : Short_Integer; pragma Import (Ada, E051, "system__soft_links_E");
   E049 : Short_Integer; pragma Import (Ada, E049, "system__exception_table_E");
   E105 : Short_Integer; pragma Import (Ada, E105, "system__bb__timing_events_E");
   E126 : Short_Integer; pragma Import (Ada, E126, "ada__real_time_E");
   E011 : Short_Integer; pragma Import (Ada, E011, "system__tasking__protected_objects_E");
   E153 : Short_Integer; pragma Import (Ada, E153, "system__tasking__protected_objects__multiprocessors_E");
   E158 : Short_Integer; pragma Import (Ada, E158, "system__tasking__restricted__stages_E");
   E009 : Short_Integer; pragma Import (Ada, E009, "activation_log_E");
   E145 : Short_Integer; pragma Import (Ada, E145, "activation_manager_E");
   E183 : Short_Integer; pragma Import (Ada, E183, "auxiliary_E");
   E160 : Short_Integer; pragma Import (Ada, E160, "external_event_server_parameters_E");
   E164 : Short_Integer; pragma Import (Ada, E164, "event_queue_E");
   E162 : Short_Integer; pragma Import (Ada, E162, "external_event_servers_E");
   E130 : Short_Integer; pragma Import (Ada, E130, "production_workload_E");
   E007 : Short_Integer; pragma Import (Ada, E007, "activation_log_reader_parameters_E");
   E143 : Short_Integer; pragma Import (Ada, E143, "activation_log_readers_E");
   E174 : Short_Integer; pragma Import (Ada, E174, "on_call_producer_parameters_E");
   E178 : Short_Integer; pragma Import (Ada, E178, "request_buffer_E");
   E176 : Short_Integer; pragma Import (Ada, E176, "on_call_producers_E");
   E181 : Short_Integer; pragma Import (Ada, E181, "regular_producer_parameters_E");
   E005 : Short_Integer; pragma Import (Ada, E005, "regular_producers_E");

   Sec_Default_Sized_Stacks : array (1 .. 5) of aliased System.Secondary_Stack.SS_Stack (System.Parameters.Runtime_Default_Sec_Stack_Size);

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
      Main_Priority := 0;
      Time_Slice_Value := 0;
      WC_Encoding := 'b';
      Locking_Policy := 'C';
      Queuing_Policy := ' ';
      Task_Dispatching_Policy := 'F';
      System.Restrictions.Run_Time_Restrictions :=
        (Set =>
          (False, True, True, False, False, False, False, True, 
           False, False, False, False, False, False, False, True, 
           True, False, False, False, False, False, True, False, 
           False, False, False, False, False, False, False, False, 
           True, True, False, False, True, True, False, False, 
           False, True, False, False, False, False, True, False, 
           True, True, False, False, False, False, True, True, 
           True, True, True, False, True, False, False, False, 
           False, False, False, False, False, False, False, False, 
           False, False, False, False, False, True, False, False, 
           False, False, False, False, False, False, True, True, 
           False, True, False, False),
         Value => (0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
         Violated =>
          (False, False, False, False, True, True, False, False, 
           False, False, False, True, True, True, True, False, 
           False, False, False, False, True, True, False, True, 
           False, False, True, True, True, True, False, False, 
           False, False, False, True, False, False, True, False, 
           False, False, True, True, False, False, False, True, 
           False, False, False, True, False, False, False, False, 
           False, False, False, True, False, True, True, True, 
           True, False, True, False, True, True, True, False, 
           True, True, False, False, True, True, True, False, 
           False, True, False, False, False, True, False, False, 
           True, False, True, False),
         Count => (0, 0, 0, 1, 0, 0, 4, 0, 5, 0),
         Unknown => (False, False, False, False, False, False, False, False, True, False));
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
      Binder_Sec_Stacks_Count := 5;
      Default_Sized_SS_Pool := Sec_Default_Sized_Stacks'Address;

      Runtime_Initialize (1);

      System.Soft_Links'Elab_Spec;
      System.Exception_Table'Elab_Body;
      E049 := E049 + 1;
      Ada.Tags'Elab_Body;
      E076 := E076 + 1;
      System.Bb.Timing_Events'Elab_Spec;
      System.Bb.Timing_Events'Elab_Body;
      E105 := E105 + 1;
      E051 := E051 + 1;
      Ada.Real_Time'Elab_Body;
      E126 := E126 + 1;
      System.Tasking.Protected_Objects'Elab_Body;
      E011 := E011 + 1;
      System.Tasking.Protected_Objects.Multiprocessors'Elab_Body;
      E153 := E153 + 1;
      System.Tasking.Restricted.Stages'Elab_Body;
      E158 := E158 + 1;
      Activation_Log'Elab_Spec;
      E009 := E009 + 1;
      Activation_Manager'Elab_Spec;
      E145 := E145 + 1;
      E183 := E183 + 1;
      E160 := E160 + 1;
      Event_Queue'Elab_Spec;
      E164 := E164 + 1;
      External_Event_Servers'Elab_Body;
      E162 := E162 + 1;
      E130 := E130 + 1;
      E007 := E007 + 1;
      Activation_Log_Readers'Elab_Body;
      E143 := E143 + 1;
      E174 := E174 + 1;
      Request_Buffer'Elab_Body;
      E178 := E178 + 1;
      On_Call_Producers'Elab_Body;
      E176 := E176 + 1;
      E181 := E181 + 1;
      Regular_Producers'Elab_Body;
      E005 := E005 + 1;
   end adainit;

   procedure Ada_Main_Program;
   pragma Import (Ada, Ada_Main_Program, "_ada_gee");

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
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/ada.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/gnat.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/interfac.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/system.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/i-stm32.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/i-stm32-pwr.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-bb.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-bbbopa.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-bbcpsp.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-bbmcpa.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-except.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-imgint.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-maccod.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-parame.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-semiho.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-stoele.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-secsta.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/g-debuti.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-casuti.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-strhas.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-htable.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-tasinf.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-textio.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-io.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-traent.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-unstyp.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/i-stm32-rcc.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-bbpara.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-stm32.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-wchcon.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-wchjis.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-wchcnv.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-addima.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-traceb.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-excdeb.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-excmac.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-multip.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-musplo.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-exctab.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-bcpcst.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-bbbosu.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-bbdead.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/a-exctra.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-memory.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-trasym.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-wchstw.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/a-tags.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-valuti.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-valuns.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-stalib.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/a-except.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-bbthqu.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-bbprot.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-bbthre.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-bbinte.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-bbcppr.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-osinte.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/a-elchha.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-taspri.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-bbtiev.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-bbtime.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-mufalo.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-tasdeb.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-taskin.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-soflin.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-taprop.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/a-reatim.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/a-retide.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-taprob.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-tpoben.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-tpobmu.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-tposen.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-tasque.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-tpobop.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-tasres.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/s-tarest.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/a-taside.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/a-sytaco.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/activation_log_parameters.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/activation_log.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/activation_manager.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/auxiliary.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/external_event_server_parameters.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/event_queue.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/external_event_servers.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/production_workload.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/activation_log_reader_parameters.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/activation_log_readers.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/on_call_producer_parameters.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/request_buffer_parameters.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/request_buffer.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/on_call_producers.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/regular_producer_parameters.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/regular_producers.o
   --   /home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/gee.o
   --   -L/home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/
   --   -L/home/aquox/Scrivania/Arm/fps-ravenscar-arm/build/
   --   -L/usr/local/gnat-arm/arm-eabi/lib/gnat/ravenscar-full-stm32f4/adalib/
   --   -static
   --   -lgnarl
   --   -lgnat
--  END Object file/option list   

end ada_main;
