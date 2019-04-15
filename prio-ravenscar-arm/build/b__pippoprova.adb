pragma Warnings (Off);
pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b__pippoprova.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b__pippoprova.adb");
pragma Suppress (Overflow_Check);

package body ada_main is

   E095 : Short_Integer; pragma Import (Ada, E095, "system__soft_links_E");
   E093 : Short_Integer; pragma Import (Ada, E093, "system__exception_table_E");
   E059 : Short_Integer; pragma Import (Ada, E059, "ada__tags_E");
   E081 : Short_Integer; pragma Import (Ada, E081, "system__bb__timing_events_E");
   E121 : Short_Integer; pragma Import (Ada, E121, "ada__real_time_E");
   E006 : Short_Integer; pragma Import (Ada, E006, "system__tasking__restricted__stages_E");
   E119 : Short_Integer; pragma Import (Ada, E119, "tasking_E");

   Sec_Default_Sized_Stacks : array (1 .. 2) of aliased System.Secondary_Stack.SS_Stack (System.Parameters.Runtime_Default_Sec_Stack_Size);

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
      Binder_Sec_Stacks_Count := 2;
      Default_Sized_SS_Pool := Sec_Default_Sized_Stacks'Address;

      Runtime_Initialize (1);

      System.Soft_Links'Elab_Spec;
      System.Exception_Table'Elab_Body;
      E093 := E093 + 1;
      Ada.Tags'Elab_Body;
      E059 := E059 + 1;
      System.Bb.Timing_Events'Elab_Spec;
      E095 := E095 + 1;
      System.Bb.Timing_Events'Elab_Body;
      E081 := E081 + 1;
      Ada.Real_Time'Elab_Body;
      E121 := E121 + 1;
      System.Tasking.Restricted.Stages'Elab_Body;
      E006 := E006 + 1;
      Tasking'Elab_Body;
      E119 := E119 + 1;
   end adainit;

   procedure Ada_Main_Program;
   pragma Import (Ada, Ada_Main_Program, "_ada_pippoprova");

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
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/ada.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/gnat.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/interfac.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/system.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/i-stm32.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/i-stm32-pwr.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-bb.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-bbbopa.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-bbcpsp.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-bbmcpa.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-except.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-imgint.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-maccod.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-parame.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-semiho.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-stoele.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-secsta.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/g-debuti.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-casuti.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-strhas.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-htable.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-tasinf.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-textio.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-io.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-traent.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-unstyp.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/i-stm32-rcc.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-bbpara.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-stm32.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-wchcon.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-wchjis.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-wchcnv.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-addima.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-traceb.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-excdeb.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-excmac.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-exctab.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/a-exctra.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-multip.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-musplo.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-bcpcst.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-bbbosu.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-memory.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-trasym.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-wchstw.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/a-tags.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-bbthqu.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-bbinte.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-bbcppr.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-osinte.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-taspri.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/a-elchha.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-valuti.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-valuns.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-stalib.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/a-except.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-tasdeb.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-taskin.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-soflin.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-bbtiev.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-bbtime.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-bbprot.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-bbthre.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-mufalo.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-taprop.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/a-reatim.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/a-retide.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-tasres.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/s-tarest.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/tasking.o
   --   /home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/pippoprova.o
   --   -L/home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/
   --   -L/home/aquox/Scrivania/edf-ravenscar-arm (copia)/build/
   --   -L/usr/local/gnat-arm/arm-eabi/lib/gnat/ravenscar-full-stm32f4/adalib/
   --   -static
   --   -lgnarl
   --   -lgnat
--  END Object file/option list   

end ada_main;
