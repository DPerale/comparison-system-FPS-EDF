with MAST, MAST.Operations, MAST.Shared_Resources,
  MAST.Processing_Resources, Mast.Processing_Resources.Processor,
  Mast.Processing_Resources.Network,
  Mast.Schedulers,Mast.Schedulers.Primary,Mast.Schedulers.Secondary,
  Mast.Scheduling_Policies,
  MAST.Events, MAST.Scheduling_Servers, MAST.IO,
  MAST.Transactions, MAST.Timing_Requirements, MAST.Graphs,
  MAST.Graphs.Links, MAST.Graphs.Event_Handlers, MAST.Systems,
  MAST.Scheduling_Parameters, Mast.Synchronization_Parameters,
  Mast.Drivers,Mast.Timers,List_Exceptions;
use MAST;
with Symbol_Table; use Symbol_Table;
with MAST_lex; Use MAST_Lex;
with MAST_lex_dfa;
with MAST_lex_io;
with Var_Strings; use Var_Strings;
with MAST_Parser_Tokens, MAST_Parser_Shift_Reduce,
  MAST_Parser_Goto,MAST_Parser_Error_Report,MAST_Lex_IO;
use MAST_Parser_Tokens, MAST_Parser_Shift_Reduce,
  MAST_Parser_Goto,MAST_Lex_IO;
with Text_IO; use Text_IO;
procedure MAST_Parser (MAST_System : out MAST.Systems.System) is

      procedure YYError (S : in String) is
      begin
          MAST_Parser_Error_Report.Report_Continuable_Error
                 (YY_Line_Number, YY_Begin_Column, YY_End_Column, S, True);
      end YYError;

      Processing_Res_Ref    : Processing_Resources.Processing_Resource_Ref;
      Proc_Res_Index        : Processing_Resources.Lists.Index;
      Scheduler_Ref         : Schedulers.Scheduler_Ref;
      Sched_Policy_Ref      : Scheduling_Policies.Scheduling_Policy_Ref;
      Shared_Res_Ref        : Shared_Resources.Shared_Resource_Ref;
      Op_Ref                : Operations.Operation_Ref;
      Evnt_Ref              : Events.Event_Ref;
      Srvr_Ref              : Scheduling_Servers.Scheduling_Server_Ref;
      Timing_Reqs_Ref,
        Sec_Timing_reqs_ref : Mast.Timing_Requirements.Timing_Requirement_Ref;
      Sched_Params_Ref      : Scheduling_Parameters.Sched_Parameters_Ref;
      Synch_Params_Ref      :
                    Synchronization_Parameters.Synch_Parameters_Ref;
      Overridden_Sched_Params_Ref :
                    Scheduling_Parameters.Overridden_Sched_Parameters_Ref;
      Trans_Ref             : Transactions.Transaction_Ref;
      An_Event_Handler_Ref  : Graphs.Event_Handler_Ref;
      A_Link_Ref           : Graphs.Link_Ref;
      A_Driver_Ref         : Drivers.Driver_Ref;
      A_Timer_Ref          : Timers.System_Timer_Ref;
      Op_Index : Operations.Lists.Index;
      Scheduler_Index      : Schedulers.Lists.Index;
      Shared_res_Index : Shared_resources.Lists.Index;
      Srvr_Index : Scheduling_Servers.Lists.Index;
      preassigned_field_present : Boolean:=False;
      Null_System : Mast.Systems.System;
      A_Name : Var_string;

      use type Operations.Lists.Index;
      use type Graphs.Link_Lists.Index;
      use type Processing_resources.Lists.Index;
      use type Schedulers.Lists.Index;
      use type Shared_resources.Lists.Index;
      use type Scheduling_Servers.Lists.Index;

procedure YYParse is

   -- Rename User Defined Packages to Internal Names.
    package yy_goto_tables         renames
      Mast_Parser_Goto;
    package yy_shift_reduce_tables renames
      Mast_Parser_Shift_Reduce;
    package yy_tokens              renames
      Mast_Parser_Tokens;
    -- UMASS CODES :
    package yy_error_report renames
      Mast_Parser_Error_Report;
    -- END OF UMASS CODES.

   use yy_tokens, yy_goto_tables, yy_shift_reduce_tables;

   procedure yyerrok;
   procedure yyclearin;

-- UMASS CODES :
--   One of the extension of ayacc. Used for
--   error recovery and error reporting.

   package yyparser_input is
   --
   -- TITLE
   --   yyparser input.
   --
   -- OVERVIEW
   --   In Ayacc, parser get the input directly from lexical scanner.
   --   In the extension, we have more power in error recovery which will
   --   try to replace, delete or insert a token into the input
   --   stream. Since general lexical scanner does not support
   --   replace, delete or insert a token, we must maintain our
   --   own input stream to support these functions. It is the
   --   purpose that we introduce yyparser_input. So parser no
   --   longer interacts with lexical scanner, instead, parser
   --   will get the input from yyparser_input. Yyparser_Input
   --   get the input from lexical scanner and supports
   --   replacing, deleting and inserting tokens.
   --

   type string_ptr is access string;

   type tokenbox is record
   --
   -- OVERVIEW
   --    Tokenbox is the type of the element of the input
   --    stream maintained in yyparser_input. It contains
   --    the value of the token, the line on which the token
   --    resides, the line number on which the token resides.
   --    It also contains the begin and end column of the token.
      token         : yy_tokens.token;
      lval          : yystype;
      line          : string_ptr;
      line_number   : natural := 1;
      token_start   : natural := 1;
      token_end     : natural := 1;
   end record;

   type boxed_token is access tokenbox;

   procedure unget(tok : in boxed_token);
   -- push a token back into input stream.

   function get return boxed_token;
   -- get a token from input stream

   procedure reset_peek;
   function peek return boxed_token;
   -- During error recovery, we will lookahead to see the
   -- affect of the error recovery. The lookahead does not
   -- means that we actually accept the input, instead, it
   -- only means that we peek the future input. It is the
   -- purpose of function peek and it is also the difference
   -- between peek and get. We maintain a counter indicating
   -- how many token we have peeked and reset_peek will
   -- reset that counter.

   function tbox (token : yy_tokens.token ) return boxed_token;
   -- Given the token got from the lexical scanner, tbox
   -- collect other information, such as, line, line number etc.
   -- to construct a boxed_token.

   input_token    : yyparser_input.boxed_token;
   previous_token : yyparser_input.boxed_token;
   -- The current and previous token processed by parser.

   end yyparser_input;

   package yyerror_recovery is
   --
   -- TITLE
   --
   --   Yyerror_Recovery.
   --
   -- OVERVIEW
   --   This package contains all of errro recovery staff,
   --   in addition to those of Ayacc.

   previous_action : integer;
   -- This variable is used to save the previous action the parser made.

   previous_error_flag : natural := 0;
   -- This variable is used to save the previous error flag.

   valuing : Boolean := True;
   -- Indicates whether to perform semantic actions. If exception
   -- is raised during semantic action after error recovery, we
   -- set valuing to False which causes no semantic actions to
   -- be invoked any more.

    procedure flag_token ( error : in Boolean := True );
    --  This procedure will point out the position of the
    --  current token.

   procedure finale;
   -- This procedure prepares the final report for error report.

   procedure try_recovery;
   -- It is the main procedure for error recovery.

   line_number : integer := 0;
   -- Indicates the last line having been outputed to the error file.

   procedure put_new_line;
   -- This procedure outputs the whole line on which input_token
   -- resides along with line number to the file for error reporting.
   end yyerror_recovery;

   use yyerror_recovery;

   package user_defined_errors is
   --
   -- TITLE
   --    User Defined Errors.
   --
   -- OVERVIEW
   --    This package is used to facilite the error reporting.

   procedure parser_error(Message : in String );
   procedure parser_warning(Message : in String );

   end user_defined_errors;

-- END OF UMASS CODES.

   package yy is

       -- the size of the value and state stacks
       stack_size : constant Natural := 300;

       -- subtype rule         is natural;
       subtype parse_state  is natural;
       -- subtype nonterminal  is integer;

       -- encryption constants
       default           : constant := -1;
       first_shift_entry : constant :=  0;
       accept_code       : constant := -3001;
       error_code        : constant := -3000;

       -- stack data used by the parser
       tos                : natural := 0;
       value_stack        : array(0..stack_size) of yy_tokens.yystype;
       state_stack        : array(0..stack_size) of parse_state;

       -- current input symbol and action the parser is on
       action             : integer;
       rule_id            : rule;
       input_symbol       : yy_tokens.token;


       -- error recovery flag
       error_flag : natural := 0;
          -- indicates  3 - (number of valid shifts after an error occurs)

       look_ahead : boolean := true;
       index      : integer;

       -- Is Debugging option on or off
        DEBUG : constant boolean := FALSE;

    end yy;


    function goto_state
      (state : yy.parse_state;
       sym   : nonterminal) return yy.parse_state;

    function parse_action
      (state : yy.parse_state;
       t     : yy_tokens.token) return integer;

    pragma inline(goto_state, parse_action);


    function goto_state(state : yy.parse_state;
                        sym   : nonterminal) return yy.parse_state is
        index : integer;
    begin
        index := goto_offset(state);
        while  integer(goto_matrix(index).nonterm) /= sym loop
            index := index + 1;
        end loop;
        return integer(goto_matrix(index).newstate);
    end goto_state;


    function parse_action(state : yy.parse_state;
                          t     : yy_tokens.token) return integer is
        index      : integer;
        tok_pos    : integer;
        default    : constant integer := -1;
    begin
        tok_pos := yy_tokens.token'pos(t);
        index   := shift_reduce_offset(state);
        while integer(shift_reduce_matrix(index).t) /= tok_pos and then
              integer(shift_reduce_matrix(index).t) /= default
        loop
            index := index + 1;
        end loop;
        return integer(shift_reduce_matrix(index).act);
    end parse_action;

-- error recovery stuff

    procedure handle_error is
      temp_action : integer;
    begin

      if yy.error_flag = 3 then -- no shift yet, clobber input.
      if yy.debug then
          text_io.put_line("Ayacc.YYParse: Error Recovery Clobbers " &
                   yy_tokens.token'image(yy.input_symbol));
-- UMASS CODES :
          yy_error_report.put_line("Ayacc.YYParse: Error Recovery Clobbers " &
                                    yy_tokens.token'image(yy.input_symbol));
-- END OF UMASS CODES.
      end if;
        if yy.input_symbol = yy_tokens.end_of_input then  -- don't discard,
        if yy.debug then
            text_io.put_line("Ayacc.YYParse: Can't discard END_OF_INPUT, quiting...");
-- UMASS CODES :
            yy_error_report.put_line("Ayacc.YYParse: Can't discard END_OF_INPUT, quiting...");
-- END OF UMASS CODES.
        end if;
-- UMASS CODES :
        yyerror_recovery.finale;
-- END OF UMASS CODES.
        raise yy_tokens.syntax_error;
        end if;

            yy.look_ahead := true;   -- get next token
        return;                  -- and try again...
    end if;

    if yy.error_flag = 0 then -- brand new error
        yyerror("Syntax Error");
-- UMASS CODES :
        yy_error_report.put_line ( "Skipping..." );
        yy_error_report.put_line ( "" );
-- END OF UMASS CODES.
    end if;

    yy.error_flag := 3;

    -- find state on stack where error is a valid shift --

    if yy.debug then
        text_io.put_line("Ayacc.YYParse: Looking for state with error as valid shift");
-- UMASS CODES :
        yy_error_report.put_line("Ayacc.YYParse: Looking for state with error as valid shift");
-- END OF UMASS CODES.
    end if;

    loop
        if yy.debug then
          text_io.put_line("Ayacc.YYParse: Examining State " &
               yy.parse_state'image(yy.state_stack(yy.tos)));
-- UMASS CODES :
          yy_error_report.put_line("Ayacc.YYParse: Examining State " &
                                   yy.parse_state'image(yy.state_stack(yy.tos)));
-- END OF UMASS CODES.
        end if;
        temp_action := parse_action(yy.state_stack(yy.tos), error);

            if temp_action >= yy.first_shift_entry then
                if yy.tos = yy.stack_size then
                    text_io.put_line(" Stack size exceeded on state_stack");
-- UMASS CODES :
                    yy_error_report.put_line(" Stack size exceeded on state_stack");
                    yyerror_recovery.finale;
-- END OF UMASS CODES.
                    raise yy_Tokens.syntax_error;
                end if;
                yy.tos := yy.tos + 1;
                yy.state_stack(yy.tos) := temp_action;
                exit;
            end if;

        Decrement_Stack_Pointer :
        begin
          yy.tos := yy.tos - 1;
        exception
          when Constraint_Error =>
            yy.tos := 0;
        end Decrement_Stack_Pointer;

        if yy.tos = 0 then
          if yy.debug then
            text_io.put_line("Ayacc.YYParse: Error recovery popped entire stack, aborting...");
-- UMASS CODES :
            yy_error_report.put_line("Ayacc.YYParse: Error recovery popped entire stack, aborting...");
-- END OF UMASS CODES.
          end if;
-- UMASS CODES :
          yyerror_recovery.finale;
-- END OF UMASS CODES.
          raise yy_tokens.syntax_error;
        end if;
    end loop;

    if yy.debug then
        text_io.put_line("Ayacc.YYParse: Shifted error token in state " &
              yy.parse_state'image(yy.state_stack(yy.tos)));
-- UMASS CODES :
        yy_error_report.put_line("Ayacc.YYParse: Shifted error token in state " &
                                 yy.parse_state'image(yy.state_stack(yy.tos)));
-- END OF UMASS CODES.
    end if;

    end handle_error;

   -- print debugging information for a shift operation
   procedure shift_debug(state_id: yy.parse_state; lexeme: yy_tokens.token) is
   begin
       text_io.put_line("Ayacc.YYParse: Shift "& yy.parse_state'image(state_id)&" on input symbol "&
               yy_tokens.token'image(lexeme) );
-- UMASS CODES :
       yy_error_report.put_line("Ayacc.YYParse: Shift "& yy.parse_state'image(state_id)&" on input symbol "&
                                yy_tokens.token'image(lexeme) );
-- END OF UMASS CODES.
   end;

   -- print debugging information for a reduce operation
   procedure reduce_debug(rule_id: rule; state_id: yy.parse_state) is
   begin
       text_io.put_line("Ayacc.YYParse: Reduce by rule "&rule'image(rule_id)&" goto state "&
               yy.parse_state'image(state_id));
-- UMASS CODES :
       yy_error_report.put_line("Ayacc.YYParse: Reduce by rule "&rule'image(rule_id)&" goto state "&
                                yy.parse_state'image(state_id));
-- END OF UMASS CODES.
   end;

   -- make the parser believe that 3 valid shifts have occured.
   -- used for error recovery.
   procedure yyerrok is
   begin
       yy.error_flag := 0;
   end yyerrok;

   -- called to clear input symbol that caused an error.
   procedure yyclearin is
   begin
       -- yy.input_symbol := yylex;
       yy.look_ahead := true;
   end yyclearin;

-- UMASS CODES :
--   Bodies of yyparser_input, yyerror_recovery, user_define_errors.

package body yyparser_input is

   input_stream_size : constant integer := 10;
   -- Input_stream_size indicates how many tokens can
   -- be hold in input stream.

   input_stream : array (0..input_stream_size-1) of boxed_token;

   index : integer := 0;           -- Indicates the position of the next
                                   -- buffered token in the input stream.
   peek_count : integer := 0;      -- # of tokens seen by peeking in the input stream.
   buffered : integer := 0;        -- # of buffered tokens in the input stream.

   function tbox(token : yy_tokens.token) return boxed_token is
     boxed : boxed_token;
     line : string ( 1 .. 1024 );
     line_length : integer;
   begin
     boxed := new tokenbox;
     boxed.token := token;
     boxed.lval := yylval;
     boxed.line_number := yy_line_number;
     yy_get_token_line(line, line_length);
     boxed.line := new String ( 1 .. line_length );
     boxed.line ( 1 .. line_length ) := line ( 1 .. line_length );
     boxed.token_start := yy_begin_column;
     boxed.token_end := yy_end_column;
     return boxed;
   end tbox;

   function get return boxed_token is
     t : boxed_token;
   begin
     if buffered = 0 then
       -- No token is buffered in the input stream
       -- so we get input from lexical scanner and return.
       return tbox(yylex);
     else
       -- return the next buffered token. And remove
       -- it from input stream.
       t := input_stream(index);
       yylval := t.lval;
       -- Increase index and decrease buffered has
       -- the affect of removing the returned token
       -- from input stream.
       index := (index + 1 ) mod input_stream_size;
       buffered := buffered - 1;
       if peek_count > 0 then
         -- Previously we were peeking the tokens
         -- from index - 1 to index - 1 + peek_count.
         -- But now token at index - 1 is returned
         -- and remove, so this token is no longer
         -- one of the token being peek. So we must
         -- decrease the peek_count. If peek_count
         -- is 0, we remains peeking 0 token, so we
         -- do nothing.
         peek_count := peek_count - 1;
       end if;
       return t;
     end if;
   end get;

   procedure reset_peek is
   -- Make it as if we have not peeked anything.
   begin
      peek_count := 0;
   end reset_peek;

   function peek return boxed_token is
      t : boxed_token;
   begin
      if peek_count = buffered then
        -- We have peeked all the buffered tokens
        -- in the input stream, so next peeked
        -- token should be got from lexical scanner.
        -- Also we must buffer that token in the
        -- input stream. It is the difference between
        -- peek and get.
        t := tbox(yylex);
        input_stream((index + buffered) mod input_stream_size) := t;
        buffered := buffered + 1;
        if buffered > input_stream_size then
          text_io.Put_Line ( "Warning : input stream size exceed."
                     & " So token is lost in the input stream." );
        end if;

      else
        -- We have not peeked all the buffered tokens,
        -- so we peek next buffered token.

        t := input_stream((index+peek_count) mod input_stream_size);
      end if;

      peek_count := peek_count + 1;
      return t;
   end peek;

   procedure unget (tok : in boxed_token) is
   begin
      -- First decrease the index.
      if index = 0 then
        index := input_stream_size - 1;
      else
        index := index - 1;
      end if;
      input_stream(index) := tok;
      buffered := buffered + 1;
      if buffered > input_stream_size then
        text_io.Put_Line ( "Warning : input stream size exceed."
                   & " So token is lost in the input stream." );
      end if;

      if peek_count > 0 then
        -- We are peeking tokens, so we must increase
        -- peek_count to maintain the correct peeking position.
        peek_count := peek_count + 1;
      end if;
   end unget;

   end yyparser_input;


    package body user_defined_errors is

      procedure parser_error(Message : in String) is
      begin
        yy_error_report.report_continuable_error
         (yyparser_input.input_token.line_number,
          yyparser_input.input_token.token_start,
          yyparser_input.input_token.token_end,
          Message,
          True);
        yy_error_report.total_errors := yy_error_report.total_errors + 1;
      end parser_error;

      procedure parser_warning(Message : in String) is
      begin
        yy_error_report.report_continuable_error
         (yyparser_input.input_token.line_number,
          yyparser_input.input_token.token_start,
          yyparser_input.input_token.token_end,
          Message,
          False);
        yy_error_report.total_warnings := yy_error_report.total_warnings + 1;
      end parser_warning;

    end user_defined_errors;


    package body yyerror_recovery is

    max_forward_moves : constant integer := 5;
    -- Indicates how many tokens we will peek at most during error recovery.

    type change_type is ( replace, insert, delete );
    -- Indicates what kind of change error recovery does to the input stream.

    type correction_type is record
       -- Indicates the correction error recovery does to the input stream.
       change    :   change_type;
       score     :   integer;
       tokenbox  :   yyparser_input.boxed_token;
    end record;

    procedure put_new_line is
      line_number_string : constant string :=
         integer'image( yyparser_input.input_token.line_number );
    begin
      yy_error_report.put(line_number_string);
      for i in 1 .. 5 - integer ( line_number_string'length ) loop
        yy_error_report.put(" ");
      end loop;
      yy_error_report.put(yyparser_input.input_token.line.all);
    end put_new_line;


    procedure finale is
    begin
      if yy_error_report.total_errors > 0 then
        yy_error_report.put_line("");
        yy_error_report.put("Ayacc.YYParse : " & natural'image(yy_error_report.total_errors));
        if yy_error_report.total_errors = 1 then
           yy_error_report.put_line(" syntax error found.");
        else
           yy_error_report.put_line(" syntax errors found.");
        end if;
        yy_error_report.Finish_Output;
        raise yy_error_report.syntax_error;
      elsif yy_error_report.total_warnings > 0 then
        yy_error_report.put_line("");
        yy_error_report.put("Ayacc.YYParse : " & natural'image(yy_error_report.total_warnings));
        if yy_error_report.total_warnings = 1 then
          yy_error_report.put_line(" syntax warning found.");
        else
          yy_error_report.put_line(" syntax warnings found.");
        end if;

        yy_error_report.Finish_Output;
        raise yy_error_report.syntax_warning;
      end if;
      yy_error_report.Finish_Output;
    end finale;

    procedure flag_token ( error : in Boolean := True ) is
    --
    -- OVERVIEW
    --    This procedure will point out the position of the
    --    current token.
    --
    begin
       if yy.error_flag > 0 then
         -- We have not seen 3 valid shift yet, so we
         -- do not need to report this error.
         return;
       end if;

       if error then
         yy_error_report.put("Error"); -- 5 characters for line number.
       else
         yy_error_report.put("OK   ");
       end if;

       for i in 1 .. yyparser_input.input_token.token_start - 1 loop
         if yyparser_input.input_token.line(i) = Ascii.ht then
           yy_error_report.put(Ascii.ht);
         else
           yy_error_report.put(" ");
         end if;
       end loop;
       yy_error_report.put_line("^");
    end flag_token;


    procedure print_correction_message (correction : in correction_type) is
    --
    -- OVERVIEW
    --    This is a local procedure used to print out the message
    --    about the correction error recovery did.
    --
    begin
      if yy.error_flag > 0 then
        -- We have not seen 3 valid shift yet, so we
        -- do not need to report this error.
        return;
      end if;

      flag_token;
      case correction.change is
        when delete =>
          yy_error_report.put("token delete " );
          user_defined_errors.parser_error("token delete " );

        when replace =>
          yy_error_report.put("token replaced by " &
                     yy_tokens.token'image(correction.tokenbox.token));
          user_defined_errors.parser_error("token replaced by " &
                     yy_tokens.token'image(correction.tokenbox.token));

        when insert =>
          yy_error_report.put("inserted token " &
                     yy_tokens.token'image(correction.tokenbox.token));
          user_defined_errors.parser_error("inserted token " &
                     yy_tokens.token'image(correction.tokenbox.token));
      end case;

      if yy.debug then
        yy_error_report.put_line("... Correction Score is" &
                                 integer'image(correction.score));
      else
        yy_error_report.put_line("");
      end if;
      yy_error_report.put_line("");
    end print_correction_message;

    procedure install_correction(correction : correction_type) is
    -- This is a local procedure used to install the correction.
    begin
        case correction.change is
          when delete  => null;
                          -- Since error found for current token,
                          -- no state is changed for current token.
                          -- If we resume Parser now, Parser will
                          -- try to read next token which has the
                          -- affect of ignoring current token.
                          -- So for deleting correction, we need to
                          -- do nothing.
          when replace => yyparser_input.unget(correction.tokenbox);
          when insert  => yyparser_input.unget(yyparser_input.input_token);
                          yyparser_input.input_token := null;
                          yyparser_input.unget(correction.tokenbox);
        end case;
    end install_correction;


    function simulate_moves return integer is
    --
    -- OVERVIEW
    --    This is a local procedure simulating the Parser work to
    --    evaluate a potential correction. It will look at most
    --    max_forward_moves tokens. It behaves very similarly as
    --    the actual Parser except that it does not invoke user
    --    action and it exits when either error is found or
    --    the whole input is accepted. Simulate_moves also
    --    collects and returns the score. Simulate_Moves
    --    do the simulation on the copied state stack to
    --    avoid changing the original one.

       -- the score for each valid shift.
       shift_increment : constant integer := 20;
       -- the score for each valid reduce.
       reduce_increment : constant integer := 10;
       -- the score for accept action.
       accept_increment : integer := 14 * max_forward_moves;
       -- the decrement for error found.
       error_decrement : integer := -10 * max_forward_moves;

       -- Indicates how many reduces made between last shift
       -- and current shift.
       current_reduces : integer := 0;

       -- Indicates how many reduces made till now.
       total_reduces : integer := 0;

       -- Indicates how many tokens seen so far during simulation.
       tokens_seen : integer := 0;

       score : integer := 0; -- the score of the simulation.

       The_Copied_Stack : array (0..yy.stack_size) of yy.parse_state;
       The_Copied_Tos   : integer;
       The_Copied_Input_Token : yyparser_input.boxed_token;
       Look_Ahead : Boolean := True;

    begin

       -- First we copy the state stack.
       for i in 0 .. yy.tos loop
         The_Copied_Stack(i) := yy.state_stack(i);
       end loop;
       The_Copied_Tos := yy.tos;
       The_Copied_Input_Token := yyparser_input.input_token;
       -- Reset peek_count because each simulation
       -- starts a new process of peeking.
       yyparser_input.reset_peek;

       -- Do the simulation.
       loop
         -- We peek at most max_forward_moves tokens during simulation.
         exit when tokens_seen = max_forward_moves;

         -- The following codes is very similar the codes in Parser.
         yy.index := shift_reduce_offset(yy.state_stack(yy.tos));
         if integer(shift_reduce_matrix(yy.index).t) = yy.default then
            yy.action := integer(shift_reduce_matrix(yy.index).act);
        else
            if look_ahead then
              look_ahead   := false;
              -- Since it is in simulation, we peek the token instead of
              -- get the token.
              The_Copied_Input_Token  := yyparser_input.peek;
            end if;
            yy.action :=
             parse_action(The_Copied_Stack(The_Copied_Tos), The_Copied_Input_Token.token);
        end if;

        if yy.action >= yy.first_shift_entry then  -- SHIFT
            if yy.debug then
                shift_debug(yy.action, The_Copied_Input_Token.token);
            end if;

            -- Enter new state
            The_Copied_Tos := The_Copied_Tos + 1;
            The_Copied_Stack(The_Copied_Tos) := yy.action;

            -- Advance lookahead
            look_ahead := true;

            score := score + shift_increment + current_reduces * reduce_increment;
            current_reduces := 0;
            tokens_seen := tokens_seen + 1;

        elsif yy.action = yy.error_code then       -- ERROR
            score := score - total_reduces * reduce_increment;
            exit; -- exit the loop for simulation.

        elsif yy.action = yy.accept_code then
            score := score + accept_increment;
            exit; -- exit the loop for simulation.

        else -- Reduce Action

            -- Convert action into a rule
            yy.rule_id  := -1 * yy.action;

            -- Don't Execute User Action

            -- Pop RHS states and goto next state
            The_Copied_Tos      := The_Copied_Tos - rule_length(yy.rule_id) + 1;
            The_Copied_Stack(The_Copied_Tos) := goto_state(The_Copied_Stack(The_Copied_Tos-1) ,
                                 get_lhs_rule(yy.rule_id));

            -- Leave value stack alone

            if yy.debug then
                reduce_debug(yy.rule_id,
                    goto_state(The_Copied_Stack(The_Copied_Tos - 1),
                               get_lhs_rule(yy.rule_id)));
            end if;

            -- reduces only credited to score when a token can be shifted
            -- but no more than 3 reduces can count between shifts
            current_reduces := current_reduces + 1;
            total_reduces := total_reduces + 1;

        end if;

      end loop; -- loop for simulation;

      yyparser_input.reset_peek;

      return score;
   end simulate_moves;



    procedure primary_recovery ( best_correction : in out correction_type;
                                 stop_score      : in integer ) is
    --
    -- OVERVIEW
    --    This is a local procedure used by try_recovery. This
    --    procedure will try the following corrections :
    --      1. Delete current token.
    --      2. Replace current token with any token acceptible
    --         from current state, or,
    --         Insert any one of the tokens acceptible from current state.
    --
      token_code      : integer;
      new_score       : integer;
      the_boxed_token : yyparser_input.boxed_token;
    begin

      -- First try to delete current token.
      if yy.debug then
        yy_error_report.put_line("trying to delete " &
                      yy_tokens.token'image(yyparser_input.input_token.token));
      end if;

      best_correction.change := delete;
      -- try to evaluate the correction. NOTE : simulating the Parser
      -- from current state has affect of ignoring current token
      -- because error was found for current token and no state
      -- was pushed to state stack.
      best_correction.score := simulate_moves;
      best_correction.tokenbox := null;

      -- If the score is less than stop_score, we try
      -- the 2nd kind of corrections, that is, replace or insert.
      if best_correction.score < stop_score then
        for i in shift_reduce_offset(yy.state_stack(yy.tos))..
                 (shift_reduce_offset(yy.state_stack(yy.tos)+1) - 1) loop
          -- We try to use the acceptible token from current state
          -- to replace current token or try to insert the acceptible token.
          token_code := integer(shift_reduce_matrix(i).t);
          -- yy.default is not a valid token, we must exit.
          exit when token_code = yy.default;

          the_boxed_token := yyparser_input.tbox(yy_tokens.token'val(token_code));
          for change in replace .. insert loop
            -- We try replacing and the inserting.
            case change is
               when replace => yyparser_input.unget(the_boxed_token);
                               -- put the_boxed_token into the input stream
                               -- has the affect of replacing current token
                               -- because current token has been retrieved
                               -- but no state was change because of the error.
                               if yy.debug then
                                  yy_error_report.put_line("trying to replace "
                                          & yy_tokens.token'image
                                             (yyparser_input.input_token.token)
                                          & " with "
                                          & yy_tokens.token'image(the_boxed_token.token));
                               end if;
               when insert  => yyparser_input.unget(yyparser_input.input_token);
                               yyparser_input.unget(the_boxed_token);
                               if yy.debug then
                                  yy_error_report.put_line("trying to insert "
                                           & yy_tokens.token'image(the_boxed_token.token)
                                           & " before "
                                           & yy_tokens.token'image(
                                                yyparser_input.input_token.token));
                               end if;
            end case;

            -- Evaluate the correction.
            new_score := simulate_moves;

            if new_score > best_correction.score then
              -- We find a higher score, so we overwrite the old one.
              best_correction := (change, new_score, the_boxed_token);
            end if;

            -- We have change the input stream when we do replacing or
            -- inserting. So we must undo the affect.
            declare
               ignore_result : yyparser_input.boxed_token;
            begin
               case change is
                 when replace => ignore_result := yyparser_input.get;
                 when insert  => ignore_result := yyparser_input.get;
                                 ignore_result := yyparser_input.get;
               end case;
            end;

            -- If we got a score higher than stop score, we
            -- feel it is good enough, so we exit.
            exit when best_correction.score > stop_score;

          end loop;  -- change in replace .. insert

          -- If we got a score higher than stop score, we
          -- feel it is good enough, so we exit.
          exit when best_correction.score > stop_score;

        end loop;  -- i in shift_reduce_offset...

      end if; -- best_correction.score < stop_score;

    end primary_recovery;


    procedure try_recovery is
    --
    -- OVERVIEW
    --   This is the main procedure doing error recovery.
    --   During the process of error recovery, we use score to
    --   evaluate the potential correction. When we try a potential
    --   correction, we will peek some future tokens and simulate
    --   the work of Parser. Any valid shift, reduce or accept action
    --   in the simulation leading from a potential correction
    --   will increase the score of the potential correction.
    --   Any error found during the simulation will decrease the
    --   score of the potential correction and stop the simulation.
    --   Since we limit the number of tokens being peeked, the
    --   simulation will stop no matter what the correction is.
    --   If the score of a potential correction is higher enough,
    --   we will accept that correction and install and let the Parser
    --   continues. During the simulation, we will do almost the
    --   same work as the actual Parser does, except that we do
    --   not invoke any user actions and we collect the score.
    --   So we will use the state_stack of the Parser. In order
    --   to avoid change the value of state_stack, we will make
    --   a copy of the state_stack and the simulation is done
    --   on the copy. Below is the outline of sequence of corrections
    --   the error recovery algorithm tries:
    --      1. Delete current token.
    --      2. Replace current token with any token acceptible
    --         from current state, or,
    --         Insert any one of the tokens acceptible from current state.
    --      3. If previous parser action is shift, back up one state,
    --         and try the corrections in 1 and 2 again.
    --      4. If none of the scores of the corrections above are highed
    --         enough, we invoke the handle_error in Ayacc.
    --
      correction : correction_type;
      backed_up  : boolean := false; -- indicates whether or not we backed up
                                     -- during error recovery.
      -- scoring : evaluate a potential correction with a number. high is good
      min_ok_score : constant integer := 70;       -- will rellluctantly use
      stop_score   : constant integer := 100;      -- this or higher is best.
    begin

      -- First try recovery without backing up.
      primary_recovery(correction, stop_score);

      if correction.score < stop_score then
        -- The score of the correction is not high enough,
        -- so we try to back up and try more corrections.
        -- But we can back up only if previous Parser action
        -- is shift.
        if previous_action >= yy.first_shift_entry then
          -- Previous action is a shift, so we back up.
          backed_up := true;

          -- we put back the input token and
          -- roll back the state stack and input token.
          yyparser_input.unget(yyparser_input.input_token);
          yyparser_input.input_token := yyparser_input.previous_token;
          yy.tos := yy.tos - 1;

          -- Then we try recovery again
          primary_recovery(correction, stop_score);
        end if;
      end if;  -- correction_score < stop_score

      -- Now we have try all possible correction.
      -- The highest score is in correction.
      if correction.score >= min_ok_score then
        -- We accept this correction.

        -- First, if the input token resides on the different line
        -- of previous token and we have not backed up, we must
        -- output the new line before we printed the error message.
        -- If we have backed up, we do nothing here because
        -- previous line has been output.
        if not backed_up and then
           ( line_number <
             yyparser_input.input_token.line_number ) then
          put_new_line;
          line_number := yyparser_input.input_token.line_number;
        end if;

        print_correction_message(correction);
        install_correction(correction);

      else
        -- No score is high enough, we try to invoke handle_error
        -- First, if we backed up during error recovery, we now must
        -- try to undo the affect of backing up.
        if backed_up then
          yyparser_input.input_token := yyparser_input.get;
          yy.tos := yy.tos + 1;
        end if;

        -- Output the new line if necessary because the
        -- new line has not been output yet.
        if line_number <
           yyparser_input.input_token.line_number then
          put_new_line;
          line_number := yyparser_input.input_token.line_number;
        end if;

        if yy.debug then
          if not backed_up then
            yy_error_report.put_line("can't back yp over last token...");
          end if;
          yy_error_report.put_line("1st level recovery failed, going to 2nd level...");
        end if;

        -- Point out the position of the token on which error occurs.
        flag_token;

        -- count it as error if it is a new error. NOTE : if correction is accepted, total_errors
        -- count will be increase during error reporting.
        if yy.error_flag = 0 then -- brand new error
          yy_error_report.total_errors := yy_error_report.total_errors + 1;
        end if;

        -- Goes to 2nd level.
        handle_error;

      end if; -- correction.score >= min_ok_score

      -- No matter what happen, let the parser move forward.
      yy.look_ahead := true;

    end try_recovery;


    end yyerror_recovery;


-- END OF UMASS CODES.

begin
    -- initialize by pushing state 0 and getting the first input symbol
    yy.state_stack(yy.tos) := 0;
-- UMASS CODES :
    yy_error_report.Initialize_Output;
    -- initialize input token and previous token
    yyparser_input.input_token := new yyparser_input.tokenbox;
    yyparser_input.input_token.line_number := 0;
-- END OF UMASS CODES.


    loop

        yy.index := shift_reduce_offset(yy.state_stack(yy.tos));
        if integer(shift_reduce_matrix(yy.index).t) = yy.default then
            yy.action := integer(shift_reduce_matrix(yy.index).act);
        else
            if yy.look_ahead then
                yy.look_ahead   := false;
-- UMASS CODES :
--    Let Parser get the input from yyparser_input instead of lexical
--    scanner and maintain previous_token and input_token.
                yyparser_input.previous_token := yyparser_input.input_token;
                yyparser_input.input_token := yyparser_input.get;
                yy.input_symbol := yyparser_input.input_token.token;
-- END OF UMASS CODES.

            end if;
            yy.action :=
             parse_action(yy.state_stack(yy.tos), yy.input_symbol);
        end if;

-- UMASS CODES :
--   If input_token is not on the line yyerror_recovery.line_number,
--   we just get to a new line. So we output the new line to
--   file of error report. But if yy.action is error, we
--   will not output the new line because we will do error
--   recovery and during error recovery, we may back up
--   which may cause error reported on previous line.
--   So if yy.action is error, we will let error recovery
--   to output the new line.
        if ( yyerror_recovery.line_number <
             yyparser_input.input_token.line_number ) and then
           yy.action /= yy.error_code then
          put_new_line;
          yyerror_recovery.line_number := yyparser_input.input_token.line_number;
        end if;
-- END OF UMASS CODES.

        if yy.action >= yy.first_shift_entry then  -- SHIFT

            if yy.debug then
                shift_debug(yy.action, yy.input_symbol);
            end if;

            -- Enter new state
            if yy.tos = yy.stack_size then
                text_io.put_line(" Stack size exceeded on state_stack");
                raise yy_Tokens.syntax_error;
            end if;
            yy.tos := yy.tos + 1;
            yy.state_stack(yy.tos) := yy.action;
-- UMASS CODES :
--   Set value stack only if valuing is True.
            if yyerror_recovery.valuing then
-- END OF UMASS CODES.
              yy.value_stack(yy.tos) := yylval;
-- UMASS CODES :
            end if;
-- END OF UMASS CODES.

        if yy.error_flag > 0 then  -- indicate a valid shift
            yy.error_flag := yy.error_flag - 1;
        end if;

            -- Advance lookahead
            yy.look_ahead := true;

        elsif yy.action = yy.error_code then       -- ERROR
-- UMASS CODES :
            try_recovery;
-- END OF UMASS CODES.


        elsif yy.action = yy.accept_code then
            if yy.debug then
                text_io.put_line("Ayacc.YYParse: Accepting Grammar...");
-- UMASS CODES :
                yy_error_report.put_line("Ayacc.YYParse: Accepting Grammar...");
-- END OF UMASS CODES.
            end if;
            exit;

        else -- Reduce Action

            -- Convert action into a rule
            yy.rule_id  := -1 * yy.action;

            -- Execute User Action
            -- user_action(yy.rule_id);

-- UMASS CODES :
--   Only invoke semantic action if valuing is True.
--   And if exception is raised during semantic action
--   and total_errors is not zero, we set valuing to False
--   because we assume that error recovery causes the exception
--   and we no longer want to invoke any semantic action.
            if yyerror_recovery.valuing then
              begin
-- END OF UMASS CODES.

                case yy.rule_id is

when  1 =>
--#line  243

        begin
           Mast.Systems.Adjust(Mast_System);
        exception
           when Mast.Object_Not_Found =>
              User_Defined_Errors.Parser_Error(Mast.Get_Exception_Message);
        end;


when  17 =>
--#line  284

        Mast_System.Model_Name:=symbol_table.item(YYVal.name_index);


when  18 =>
--#line  290

        Mast_System.Model_Date:=YYVal.date;
        if not Mast.IO.Is_Date_OK(Mast_System.Model_Date) then
            User_Defined_Errors.Parser_Error
                 ("Error in date value");
        end if;


when  19 =>
--#line  300

        if YYVal.flag then
            Mast_System.System_Pip_Behaviour:=(Mast.Systems.Strict);
        else
            Mast_System.System_Pip_Behaviour:=(Mast.Systems.Posix);
        end if;


when  24 =>
--#line  326

          processing_res_ref:=
             new Processing_resources.Processor.Regular_Processor;
          scheduler_ref:=
             new Schedulers.Primary.Primary_Scheduler;
          Schedulers.Primary.Set_Host
            (Schedulers.Primary.Primary_Scheduler(Scheduler_Ref.all),
             processing_res_ref);
          sched_policy_ref:=
             new Scheduling_Policies.Fixed_Priority;
          Schedulers.Set_Scheduling_Policy
            (Scheduler_Ref.all,Sched_Policy_Ref);


when  41 =>
--#line  364

          a_name:=symbol_table.item(YYVal.name_index);
          Processing_Resources.init(processing_res_ref.all,a_name);
          begin
             Processing_resources.lists.add
               (processing_res_ref,mast_system.processing_resources);
          exception
            when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("Processing resource already exists");
          end;
          Schedulers.init(Scheduler_ref.all,a_name);
          begin
             Schedulers.lists.add
               (scheduler_ref,mast_system.schedulers);
          exception
            when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("Scheduler already exists");
          end;


when  42 =>
--#line  388

        Scheduling_Policies.set_worst_context_switch
             (Scheduling_Policies.fixed_priority'Class
              (sched_policy_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));


when  43 =>
--#line  397

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Priority should be integer value");
        end if;
        begin
           Scheduling_Policies.set_max_priority
             (Scheduling_Policies.Fixed_Priority_Policy'class
               (sched_policy_ref.all),MAST.Priority(YYval.num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority value out of range");
        end;


when  44 =>
--#line  415

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Priority should be integer value");
        end if;
        begin
           Scheduling_Policies.set_min_priority
             (Scheduling_Policies.Fixed_Priority_Policy'class
              (sched_policy_ref.all),MAST.Priority(YYval.num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority value out of range");
        end;


when  45 =>
--#line  433

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Priority should be integer value");
        end if;
        begin
           Processing_Resources.Processor.set_max_interrupt_priority
             (Processing_resources.Processor.Regular_Processor'Class
              (processing_res_ref.all),MAST.Priority(YYval.num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority value out of range");
        end;


when  46 =>
--#line  451

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Priority should be integer value");
        end if;
        begin
           Processing_Resources.Processor.set_min_interrupt_priority
             (Processing_resources.Processor.Regular_Processor'Class
              (processing_res_ref.all),MAST.Priority(YYval.num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority value out of range");
        end;


when  47 =>
--#line  469

        Scheduling_Policies.set_avg_context_switch
             (Scheduling_Policies.fixed_priority'Class
              (sched_policy_ref.all),
              MAST.Normalized_Execution_Time(YYVal.float_num));


when  48 =>
--#line  478

        Scheduling_Policies.set_best_context_switch
             (Scheduling_Policies.fixed_priority'Class
              (sched_policy_ref.all),
              MAST.Normalized_Execution_Time(YYVal.float_num));


when  49 =>
--#line  487

        Processing_Resources.processor.set_worst_isr_switch
             (Processing_resources.Processor.Regular_Processor'Class
              (processing_res_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));


when  50 =>
--#line  496

        Processing_Resources.processor.set_avg_isr_switch
             (Processing_resources.processor.regular_processor'class
              (processing_res_ref.all),
              MAST.Normalized_Execution_Time(YYVal.float_num));


when  51 =>
--#line  505

        Processing_Resources.processor.set_best_isr_switch
             (Processing_resources.processor.regular_processor'class
              (processing_res_ref.all),
              MAST.Normalized_Execution_Time(YYVal.float_num));


when  52 =>
--#line  514

        Processing_Resources.Processor.set_system_timer
             (Processing_resources.Processor.Regular_Processor'Class
              (processing_res_ref.all),A_Timer_Ref);


when  53 =>
--#line  522

        Processing_Resources.set_speed_factor(processing_res_ref.all,
              Mast.Processor_Speed(YYVal.float_num));


when  54 =>
--#line  534

          processing_res_ref:=
             new Processing_resources.Processor.Regular_Processor;


when  66 =>
--#line  558

          a_name:=symbol_table.item(YYVal.name_index);
          Processing_Resources.init(processing_res_ref.all,a_name);
          begin
             Processing_resources.lists.add
               (processing_res_ref,mast_system.processing_resources);
          exception
            when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("Processing resource already exists");
          end;


when  69 =>
--#line  581

          A_Timer_Ref:=new Timers.Alarm_Clock;


when  77 =>
--#line  600

        Timers.set_worst_overhead
          (A_Timer_Ref.all,MAST.Normalized_Execution_Time(YYVal.float_num));


when  78 =>
--#line  607

        Timers.set_best_overhead
          (A_Timer_Ref.all,MAST.Normalized_Execution_Time(YYVal.float_num));


when  79 =>
--#line  614

        Timers.set_avg_overhead
          (A_Timer_Ref.all,MAST.Normalized_Execution_Time(YYVal.float_num));


when  80 =>
--#line  621

          A_Timer_Ref:=new Timers.Ticker;


when  89 =>
--#line  641

        Timers.set_period
          (Timers.Ticker'Class(A_Timer_Ref.all),
           MAST.Time(YYVal.float_num));


when  90 =>
--#line  654

          processing_res_ref:=
              new Processing_resources.network.Packet_Based_Network;
          scheduler_ref:=
             new Schedulers.Primary.Primary_Scheduler;
          Schedulers.Primary.Set_Host
            (Schedulers.Primary.Primary_Scheduler(Scheduler_Ref.all),
             processing_res_ref);
          sched_policy_ref:=
             new Scheduling_Policies.FP_Packet_Based;
          Schedulers.Set_Scheduling_Policy
            (Scheduler_Ref.all,Sched_Policy_Ref);


when  106 =>
--#line  691

        Scheduling_Policies.set_packet_worst_overhead
             (Scheduling_Policies.FP_Packet_Based'Class
                   (Sched_Policy_ref.all),
                    MAST.Normalized_Execution_Time(YYVal.float_num));


when  107 =>
--#line  700

        Scheduling_Policies.set_packet_overhead_max_size
             (Scheduling_Policies.FP_Packet_Based'Class
                   (Sched_Policy_ref.all),
                    MAST.Bit_Count(YYVal.float_num));


when  108 =>
--#line  709

        Scheduling_Policies.set_packet_avg_overhead
             (Scheduling_Policies.FP_Packet_Based'Class
                   (Sched_Policy_ref.all),
                 MAST.Normalized_Execution_Time(YYVal.float_num));


when  109 =>
--#line  718

        Scheduling_Policies.set_packet_overhead_avg_size
             (Scheduling_Policies.FP_Packet_Based'Class
                   (Sched_Policy_ref.all),
                    MAST.Bit_Count(YYVal.float_num));


when  110 =>
--#line  727

        Scheduling_Policies.set_packet_best_overhead
             (Scheduling_Policies.FP_Packet_Based'Class
                   (Sched_Policy_ref.all),
                 MAST.Normalized_Execution_Time(YYVal.float_num));


when  111 =>
--#line  736

        Scheduling_Policies.set_packet_overhead_min_size
             (Scheduling_Policies.FP_Packet_Based'Class
                   (Sched_Policy_ref.all),
                    MAST.Bit_Count(YYVal.float_num));


when  112 =>
--#line  745

        Processing_Resources.network.set_Transmission_Mode
             (Processing_resources.network.Packet_Based_Network'class
                (processing_res_ref.all),
                 MAST.Transmission_Kind'Val(YYVal.num));


when  114 =>
--#line  757

        Processing_Resources.network.set_max_blocking
             (Processing_resources.network.Packet_Based_Network'class
                  (processing_res_ref.all),
                   MAST.Normalized_Execution_Time(YYVal.float_num));


when  115 =>
--#line  766

        if YYVal.float_num<=0.0 then
             User_Defined_Errors.Parser_Error
                 ("Max_Packet_Transmission_Time must be greater than zero");
        else
           Processing_Resources.network.set_max_packet_transmission_time
             (Processing_resources.network.Packet_Based_Network'class
                  (processing_res_ref.all),
                   MAST.Normalized_Execution_Time(YYVal.float_num));
        end if;


when  116 =>
--#line  780

        if YYVal.float_num<=0.0 then
             User_Defined_Errors.Parser_Error
                 ("Min_Packet_Transmission_Time must be greater than zero");
        else
           Processing_Resources.network.set_min_packet_transmission_time
             (Processing_resources.network.Packet_Based_Network'class
                  (processing_res_ref.all),
                   MAST.Normalized_Execution_Time(YYVal.float_num));
        end if;


when  117 =>
--#line  794

        Processing_Resources.set_speed_factor (processing_res_ref.all,
                   MAST.Processor_Speed(YYVal.float_num));


when  121 =>
--#line  813

          processing_res_ref:=
              new Processing_resources.network.Packet_Based_Network;


when  133 =>
--#line  837

        Processing_Resources.Network.set_throughput
            (Processing_Resources.Network.Network'class
                 (processing_res_ref.all),
             MAST.Throughput_Value(YYVal.float_num));


when  138 =>
--#line  854

        if YYVal.float_num<=0.0 then
             User_Defined_Errors.Parser_Error
                 ("Max_Packet_Size must be greater than zero");
        else
           Processing_Resources.network.set_max_packet_size
             (Processing_resources.network.Packet_Based_Network'class
                  (processing_res_ref.all),MAST.Bit_Count(YYVal.float_num));
        end if;


when  139 =>
--#line  867

        if YYVal.float_num<=0.0 then
             User_Defined_Errors.Parser_Error
                 ("Min_Packet_Size must be greater than zero");
        else
           Processing_Resources.network.set_min_packet_size
             (Processing_resources.network.Packet_Based_Network'class
                  (processing_res_ref.all),MAST.Bit_Count(YYVal.float_num));
        end if;


when  140 =>
--#line  885

        Processing_Resources.network.Add_driver
          (Processing_Resources.network.Packet_Based_Network'Class
             (Processing_res_ref.all),
              A_Driver_Ref);


when  144 =>
--#line  899

          A_Driver_Ref:=new Drivers.Packet_Driver;


when  156 =>
--#line  924

          a_name:=symbol_table.item(YYVal.name_index);
          Srvr_Index:=Scheduling_Servers.Lists.Find
              (a_name,MAST_System.Scheduling_Servers);
          if Srvr_Index=Scheduling_Servers.Lists.Null_Index then
             declare
                 Srvr_Ref : Scheduling_Servers.Scheduling_Server_ref:=
                             new Scheduling_Servers.Scheduling_Server;
             begin
                 Scheduling_Servers.Init(Srvr_Ref.all,A_Name);
                 Drivers.Set_Packet_Server
                     (Drivers.Packet_Driver'Class(a_driver_ref.all),
                      Srvr_Ref);
             end;
          else
             declare
                 srvr_ref : Scheduling_Servers.Scheduling_Server_ref;
             begin
                 srvr_ref:=Scheduling_Servers.Lists.Item
                      (Srvr_Index,
                       MAST_System.Scheduling_Servers);
                 Drivers.Set_Packet_Server
                     (Drivers.Packet_Driver'Class(a_driver_ref.all),
                      Srvr_Ref);
             end;
          end if;


when  157 =>
--#line  954

         Drivers.Set_Packet_Server
           (Drivers.Packet_Driver'Class(a_driver_ref.all),
            Srvr_Ref);


when  160 =>
--#line  966

         Drivers.Set_Packet_Send_Operation
           (Drivers.Packet_Driver'Class(a_driver_ref.all),Op_Ref);


when  161 =>
--#line  973

          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Drivers.Set_Packet_Send_Operation
                    (Drivers.Packet_Driver'Class(a_driver_ref.all),Op_Ref);
             end;
          else
             declare
                 Op_ref : Operations.Operation_ref;
             begin
                 Op_ref:=Operations.Lists.Item
                     (Op_Index,MAST_System.Operations);
                 Drivers.Set_Packet_Send_Operation
                     (Drivers.Packet_Driver'Class(a_driver_ref.all),Op_Ref);
             end;
          end if;


when  164 =>
--#line  1004

         Drivers.Set_Packet_Receive_Operation
           (Drivers.Packet_Driver'Class(a_driver_ref.all),Op_Ref);


when  165 =>
--#line  1011

          A_Name:=Symbol_Table.Item(YYVal.Name_Index);
          Op_Index:=Operations.Lists.Find
              (A_Name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Drivers.Set_Packet_Receive_Operation
                    (Drivers.Packet_Driver'Class(a_driver_ref.all),Op_Ref);
             end;
          else
             declare
                 Op_ref : Operations.Operation_ref;
             begin
                 Op_ref:=Operations.Lists.Item
                     (Op_Index,MAST_System.Operations);
                 Drivers.Set_Packet_Receive_Operation
                     (Drivers.Packet_Driver'Class(a_driver_ref.all),Op_Ref);
             end;
          end if;


when  166 =>
--#line  1038

         Drivers.Set_Message_Partitioning
           (Drivers.Packet_Driver'Class(a_driver_ref.all),
            YYVal.Flag);


when  167 =>
--#line  1046

         begin
           Drivers.Set_Rta_Overhead_Model
           (Drivers.Packet_Driver'Class(a_driver_ref.all),
            Drivers.Rta_Overhead_Model_Type'Val(YYVal.Num));
         exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Overhead Model is invalid");
         end;


when  168 =>
--#line  1060

          A_Driver_Ref:=new Drivers.Character_Packet_Driver;


when  184 =>
--#line  1089

          a_name:=symbol_table.item(YYVal.name_index);
          Srvr_Index:=Scheduling_Servers.Lists.Find
              (a_name,MAST_System.Scheduling_Servers);
          if Srvr_Index=Scheduling_Servers.Lists.Null_Index then
             declare
                 Srvr_Ref : Scheduling_Servers.Scheduling_Server_ref:=
                             new Scheduling_Servers.Scheduling_Server;
             begin
                 Scheduling_Servers.Init(Srvr_Ref.all,A_Name);
                 Drivers.Set_Character_Server
                     (Drivers.Character_Packet_Driver'Class(a_driver_ref.all),
                      Srvr_Ref);
             end;
          else
             declare
                 srvr_ref : Scheduling_Servers.Scheduling_Server_ref;
             begin
                 srvr_ref:=Scheduling_Servers.Lists.Item
                      (Srvr_Index,
                       MAST_System.Scheduling_Servers);
                 Drivers.Set_Character_Server
                     (Drivers.Character_Packet_Driver'Class(a_driver_ref.all),
                      Srvr_Ref);
             end;
          end if;


when  185 =>
--#line  1119

         Drivers.Set_Character_Server
           (Drivers.Character_Packet_Driver'Class(a_driver_ref.all),
            Srvr_Ref);


when  188 =>
--#line  1131

         Drivers.Set_Character_Send_Operation
           (Drivers.Character_Packet_Driver'Class(a_driver_ref.all),Op_Ref);


when  189 =>
--#line  1138

          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Drivers.Set_Character_Send_Operation
                    (Drivers.Character_Packet_Driver'Class(a_driver_ref.all),
                     Op_Ref);
             end;
          else
             declare
                 Op_ref : Operations.Operation_ref;
             begin
                 Op_ref:=Operations.Lists.Item
                     (Op_Index,MAST_System.Operations);
                 Drivers.Set_Character_Send_Operation
                     (Drivers.Character_Packet_Driver'Class(a_driver_ref.all),
                      Op_Ref);
             end;
          end if;


when  192 =>
--#line  1172

         Drivers.Set_Character_Receive_Operation
           (Drivers.Character_Packet_Driver'Class(a_driver_ref.all),Op_Ref);


when  193 =>
--#line  1179

          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Drivers.Set_Character_Receive_Operation
                    (Drivers.Character_Packet_Driver'Class(a_driver_ref.all),
                     Op_Ref);
             end;
          else
             declare
                 Op_ref : Operations.Operation_ref;
             begin
                 Op_ref:=Operations.Lists.Item
                     (Op_Index,MAST_System.Operations);
                 Drivers.Set_Character_Receive_Operation
                     (Drivers.Character_Packet_Driver'Class(a_driver_ref.all),
                      Op_Ref);
             end;
          end if;


when  194 =>
--#line  1209

         Drivers.Set_Character_Transmission_Time
           (Drivers.Character_Packet_Driver'Class(a_driver_ref.all),
            MAST.Time(YYVal.float_num));


when  195 =>
--#line  1218

          A_Driver_Ref:=new Drivers.RTEP_Packet_Driver;


when  217 =>
--#line  1252

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Number_Of_Stations should be integer value");
        end if;
        begin
           Drivers.Set_Number_Of_Stations
              (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
               Positive(YYVal.num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Number_Of_Stations value out of range");
        end;


when  218 =>
--#line  1271

         Drivers.Set_Token_Delay
           (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
            MAST.Time(YYVal.float_num));


when  219 =>
--#line  1280

         Drivers.Set_Failure_Timeout
           (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
            MAST.Time(YYVal.float_num));


when  220 =>
--#line  1289

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Token_Transmission_Retries should be integer value");
        end if;
        begin
           Drivers.Set_Token_Transmission_Retries
              (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
               Natural(YYVal.num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Token_Transmission_Retries value out of range");
        end;


when  221 =>
--#line  1308

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Packet_Transmission_Retries should be integer value");
        end if;
        begin
           Drivers.Set_Packet_Transmission_Retries
              (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
               Natural(YYVal.num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Packet_Transmission_Retries value out of range");
        end;


when  224 =>
--#line  1330

          a_name:=symbol_table.item(YYVal.name_index);
          Srvr_Index:=Scheduling_Servers.Lists.Find
              (a_name,MAST_System.Scheduling_Servers);
          if Srvr_Index=Scheduling_Servers.Lists.Null_Index then
             declare
                 Srvr_Ref : Scheduling_Servers.Scheduling_Server_ref:=
                             new Scheduling_Servers.Scheduling_Server;
             begin
                 Scheduling_Servers.Init(Srvr_Ref.all,A_Name);
                 Drivers.Set_Packet_Interrupt_Server
                     (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                      Srvr_Ref);
             end;
          else
             declare
                 srvr_ref : Scheduling_Servers.Scheduling_Server_ref;
             begin
                 srvr_ref:=Scheduling_Servers.Lists.Item
                      (Srvr_Index,
                       MAST_System.Scheduling_Servers);
                 Drivers.Set_Packet_Interrupt_Server
                     (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                      Srvr_Ref);
             end;
          end if;


when  225 =>
--#line  1360

         Drivers.Set_Packet_Interrupt_Server
           (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
            Srvr_Ref);


when  228 =>
--#line  1372

         Drivers.Set_Packet_ISR_Operation
           (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),Op_Ref);


when  229 =>
--#line  1379

          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Drivers.Set_Packet_ISR_Operation
                    (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                     Op_Ref);
             end;
          else
             declare
                 Op_ref : Operations.Operation_ref;
             begin
                 Op_ref:=Operations.Lists.Item
                     (Op_Index,MAST_System.Operations);
                 Drivers.Set_Packet_ISR_Operation
                     (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                      Op_Ref);
             end;
          end if;


when  232 =>
--#line  1412

         Drivers.Set_Token_Check_Operation
           (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),Op_Ref);


when  233 =>
--#line  1419

          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Drivers.Set_Token_Check_Operation
                    (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                     Op_Ref);
             end;
          else
             declare
                 Op_ref : Operations.Operation_ref;
             begin
                 Op_ref:=Operations.Lists.Item
                     (Op_Index,MAST_System.Operations);
                 Drivers.Set_Token_Check_Operation
                     (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                      Op_Ref);
             end;
          end if;


when  236 =>
--#line  1452

         Drivers.Set_Token_Manage_Operation
           (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),Op_Ref);


when  237 =>
--#line  1459

          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Drivers.Set_Token_Manage_Operation
                    (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                     Op_Ref);
             end;
          else
             declare
                 Op_ref : Operations.Operation_ref;
             begin
                 Op_ref:=Operations.Lists.Item
                     (Op_Index,MAST_System.Operations);
                 Drivers.Set_Token_Manage_Operation
                     (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                      Op_Ref);
             end;
          end if;


when  240 =>
--#line  1492

         Drivers.Set_Packet_Discard_Operation
           (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),Op_Ref);


when  241 =>
--#line  1499

          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Drivers.Set_Packet_Discard_Operation
                    (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                     Op_Ref);
             end;
          else
             declare
                 Op_ref : Operations.Operation_ref;
             begin
                 Op_ref:=Operations.Lists.Item
                     (Op_Index,MAST_System.Operations);
                 Drivers.Set_Packet_Discard_Operation
                     (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                      Op_Ref);
             end;
          end if;


when  244 =>
--#line  1533

         Drivers.Set_Token_Retransmission_Operation
           (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),Op_Ref);


when  245 =>
--#line  1540

          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Drivers.Set_Token_Retransmission_Operation
                    (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                     Op_Ref);
             end;
          else
             declare
                 Op_ref : Operations.Operation_ref;
             begin
                 Op_ref:=Operations.Lists.Item
                     (Op_Index,MAST_System.Operations);
                 Drivers.Set_Token_Retransmission_Operation
                     (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                      Op_Ref);
             end;
          end if;


when  248 =>
--#line  1574

         Drivers.Set_Packet_Retransmission_Operation
           (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),Op_Ref);


when  249 =>
--#line  1581

          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Drivers.Set_Packet_Retransmission_Operation
                    (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                     Op_Ref);
             end;
          else
             declare
                 Op_ref : Operations.Operation_ref;
             begin
                 Op_ref:=Operations.Lists.Item
                     (Op_Index,MAST_System.Operations);
                 Drivers.Set_Packet_Retransmission_Operation
                     (Drivers.RTEP_Packet_Driver'Class(a_driver_ref.all),
                      Op_Ref);
             end;
          end if;


when  252 =>
--#line  1624

          scheduler_ref:=
             new Schedulers.Primary.Primary_Scheduler;


when  259 =>
--#line  1643

          a_name:=symbol_table.item(YYVal.name_index);
          Schedulers.init(Scheduler_ref.all,a_name);
          begin
             Schedulers.lists.add
               (scheduler_ref,mast_system.schedulers);
          exception
            when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("Scheduler already exists");
          end;


when  260 =>
--#line  1658

        Schedulers.set_scheduling_policy
             (scheduler_ref.all,Sched_policy_Ref);


when  261 =>
--#line  1665

          a_name:=symbol_table.item(YYVal.name_index);
          Proc_res_Index:=Processing_Resources.Lists.Find
              (a_name,MAST_System.Processing_Resources);
          if Proc_Res_Index=Processing_Resources.Lists.Null_Index then
             declare
                 Proc_Ref : Processing_Resources.Processing_Resource_ref:=
                        new Processing_Resources.Processor.Regular_Processor;
             begin
                 Processing_Resources.Init(Proc_Ref.all,A_Name);
                 Schedulers.Primary.Set_Host
                   (Schedulers.Primary.Primary_Scheduler'class
                     (Scheduler_Ref.all),proc_ref);
             end;
          else
             declare
                 proc_ref : Processing_Resources.Processing_Resource_ref;
             begin
                 proc_ref:=Processing_Resources.Lists.Item
                      (Proc_Res_index,MAST_System.Processing_Resources);
                 Schedulers.Primary.Set_Host
                   (Schedulers.Primary.Primary_Scheduler'class
                     (Scheduler_Ref.all),proc_ref);
             end;
          end if;


when  262 =>
--#line  1699

          scheduler_ref:=
             new Schedulers.Secondary.Secondary_Scheduler;


when  269 =>
--#line  1718

          a_name:=symbol_table.item(YYVal.name_index);
          Srvr_Index:=Scheduling_Servers.Lists.Find
              (a_name,MAST_System.Scheduling_Servers);
          if Srvr_Index=Scheduling_Servers.Lists.Null_Index then
             declare
                 Srvr_Ref : Scheduling_Servers.Scheduling_Server_ref:=
                             new Scheduling_Servers.Scheduling_Server;
             begin
                 Scheduling_Servers.Init(Srvr_Ref.all,A_Name);
                 Schedulers.Secondary.Set_Server
                   (Schedulers.Secondary.Secondary_Scheduler'class
                     (Scheduler_Ref.all),Srvr_ref);
             end;
          else
             declare
                 ss_ref : Scheduling_Servers.Scheduling_Server_ref;
             begin
                 ss_ref:=Scheduling_Servers.Lists.Item
                      (Srvr_index,MAST_System.Scheduling_Servers);
                 Schedulers.Secondary.Set_Server
                   (Schedulers.Secondary.Secondary_Scheduler'class
                     (Scheduler_Ref.all),ss_ref);
             end;
          end if;


when  273 =>
--#line  1757

          sched_policy_ref:=new Scheduling_Policies.fixed_priority;


when  285 =>
--#line  1783

          sched_policy_ref:=new Scheduling_Policies.edf;


when  296 =>
--#line  1806

        Scheduling_Policies.set_worst_context_switch
             (Scheduling_Policies.edf'Class
              (sched_policy_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));


when  297 =>
--#line  1815

        Scheduling_Policies.set_avg_context_switch
             (Scheduling_Policies.edf'Class
              (sched_policy_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));


when  298 =>
--#line  1824

        Scheduling_Policies.set_best_context_switch
             (Scheduling_Policies.edf'Class
              (sched_policy_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));


when  299 =>
--#line  1834

          sched_policy_ref:=new Scheduling_Policies.fp_packet_based;


when  320 =>
--#line  1886

          shared_res_ref:=new Shared_Resources.priority_inheritance_resource;


when  323 =>
--#line  1896

          a_name:=symbol_table.item(YYVal.name_index);
          Shared_Resources.init(shared_res_ref.all,a_name);
          begin
             Shared_Resources.lists.add
                (shared_res_ref,mast_system.shared_resources);
          exception
            when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("Shared resource already exists");
          end;


when  324 =>
--#line  1915

          shared_res_ref:=new Shared_Resources.immediate_ceiling_resource;
          preassigned_field_present:=False;


when  333 =>
--#line  1938

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Priority should be integer value");
        end if;
        begin
           Shared_Resources.set_ceiling
               (Shared_resources.immediate_ceiling_resource'Class
                (shared_res_ref.all),
                mast.priority(YYVal.num));
           if not Preassigned_Field_Present then
              Shared_Resources.set_preassigned
                  (Shared_resources.immediate_ceiling_resource'Class
                   (shared_res_ref.all),true);
           end if;
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority value out of range");
        end;


when  334 =>
--#line  1962

        Preassigned_Field_Present:=True;
        Shared_Resources.set_preassigned
          (Shared_resources.immediate_ceiling_resource'Class
              (shared_res_ref.all),YYVal.flag);


when  335 =>
--#line  1976

          shared_res_ref:=new Shared_Resources.srp_resource;
          preassigned_field_present:=False;


when  344 =>
--#line  1999

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Preemption level should be integer value");
        end if;
        begin
           Shared_Resources.set_level
               (Shared_resources.srp_resource'Class
                (shared_res_ref.all),
                mast.preemption_level(YYVal.num));
           if not Preassigned_Field_Present then
              Shared_Resources.set_preassigned
                  (Shared_resources.srp_resource'Class
                   (shared_res_ref.all),true);
           end if;
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Preemption level value out of range");
        end;


when  345 =>
--#line  2023

        Preassigned_Field_Present:=True;
        Shared_Resources.set_preassigned
          (Shared_resources.srp_resource'Class
              (shared_res_ref.all),YYVal.flag);


when  351 =>
--#line  2051

          Op_Ref:=new Operations.Simple_Operation;


when  361 =>
--#line  2072

        a_name:=symbol_table.item(YYVal.name_index);
        Operations.init(Op_Ref.all,a_name);
        begin
             Operations.lists.add
                  (Op_Ref,mast_system.operations);
        exception
            when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("Operation already exists");
        end;


when  362 =>
--#line  2087

        Operations.set_new_sched_parameters
             (Op_Ref.all,
              overridden_sched_params_ref);


when  363 =>
--#line  2095

        Operations.set_worst_case_execution_time
             (Operations.Simple_Operation'Class(Op_Ref.all),
              MAST.Normalized_Execution_Time(YYval.float_Num));


when  364 =>
--#line  2103

        Operations.set_avg_case_execution_time
             (Operations.Simple_Operation'Class(Op_Ref.all),
              MAST.Normalized_Execution_Time(YYval.float_Num));


when  365 =>
--#line  2111

        Operations.set_best_case_execution_time
             (Operations.Simple_Operation'Class(Op_Ref.all),
              MAST.Normalized_Execution_Time(YYval.float_Num));


when  371 =>
--#line  2131

          a_name:=symbol_table.item(YYVal.name_index);
          Shared_Res_Index:=Shared_Resources.Lists.Find
              (a_name,MAST_System.Shared_resources);
          if Shared_Res_Index=Shared_Resources.Lists.Null_Index then
             declare
                 Sh_Res_Ref : Shared_Resources.Shared_Resource_ref:=
                          new Shared_Resources.Priority_Inheritance_Resource;
             begin
                 Shared_Resources.Init(Sh_Res_Ref.all,A_Name);
                 Operations.Add_Resource
                    (Operations.Simple_Operation(Op_Ref.all),Sh_Res_Ref);
             end;
          else
              Operations.Add_Resource
                  (Operations.Simple_Operation(Op_Ref.all),
                   Shared_Resources.Lists.Item
                      (Shared_Res_Index,MAST_System.Shared_resources));
          end if;


when  377 =>
--#line  2166

          a_name:=symbol_table.item(YYVal.name_index);
          Shared_Res_Index:=Shared_Resources.Lists.Find
              (a_name,MAST_System.Shared_resources);
          if Shared_Res_Index=Shared_Resources.Lists.Null_Index then
             declare
                 Sh_Res_Ref : Shared_Resources.Shared_Resource_ref:=
                          new Shared_Resources.Priority_Inheritance_Resource;
             begin
                 Shared_Resources.Init(Sh_Res_Ref.all,A_Name);
                 Operations.Add_Locked_Resource
                    (Operations.Simple_Operation(Op_Ref.all),Sh_Res_Ref);
             end;
          else
              Operations.Add_Locked_Resource
                  (Operations.Simple_Operation(Op_Ref.all),
                   Shared_Resources.Lists.Item
                      (Shared_Res_Index,MAST_System.Shared_resources));
          end if;


when  381 =>
--#line  2197

          a_name:=symbol_table.item(YYVal.name_index);
          Shared_Res_Index:=Shared_Resources.Lists.Find
              (a_name,MAST_System.Shared_resources);
          if Shared_Res_Index=Shared_Resources.Lists.Null_Index then
             declare
                 Sh_Res_Ref : Shared_Resources.Shared_Resource_ref:=
                          new Shared_Resources.Priority_Inheritance_Resource;
             begin
                 Shared_Resources.Init(Sh_Res_Ref.all,A_Name);
                 Operations.Add_Unlocked_Resource
                    (Operations.Simple_Operation(Op_Ref.all),Sh_Res_Ref);
             end;
          else
              Operations.Add_Unlocked_Resource
                  (Operations.Simple_Operation(Op_Ref.all),
                   Shared_Resources.Lists.Item
                      (Shared_Res_Index,MAST_System.Shared_resources));
          end if;


when  382 =>
--#line  2224

          Op_Ref:=new Operations.Composite_Operation;


when  392 =>
--#line  2250

          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare
                 New_Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(New_Op_Ref.all,A_Name);
                 Operations.Add_Operation
                     (Operations.Composite_Operation(Op_Ref.all),New_Op_Ref);
             end;
          else
              Operations.Add_Operation
                  (Operations.Composite_Operation(Op_Ref.all),
                   Operations.Lists.Item(Op_Index,MAST_System.Operations));
          end if;


when  393 =>
--#line  2276

          Op_Ref:=new Operations.Enclosing_Operation;


when  403 =>
--#line  2297

        Operations.set_worst_case_execution_time
             (Operations.Enclosing_Operation'Class(Op_Ref.all),
              MAST.Normalized_Execution_Time(YYval.float_Num));


when  404 =>
--#line  2305

        Operations.set_avg_case_execution_time
             (Operations.Enclosing_Operation'Class(Op_Ref.all),
              MAST.Normalized_Execution_Time(YYval.float_Num));


when  405 =>
--#line  2313

        Operations.set_best_case_execution_time
             (Operations.Enclosing_Operation'Class(Op_Ref.all),
              MAST.Normalized_Execution_Time(YYval.float_Num));


when  407 =>
--#line  2329

          Op_Ref:=new Operations.Message_Transmission_Operation;


when  416 =>
--#line  2349

        Operations.set_max_message_size
             (Operations.Message_Transmission_Operation'Class(Op_Ref.all),
              MAST.Bit_Count(YYval.float_Num));


when  417 =>
--#line  2357

        Operations.set_avg_message_size
             (Operations.Message_Transmission_Operation'Class(Op_Ref.all),
              MAST.Bit_Count(YYval.float_Num));


when  418 =>
--#line  2365

        Operations.set_min_message_size
             (Operations.Message_Transmission_Operation'Class(Op_Ref.all),
              MAST.Bit_Count(YYval.float_Num));


when  425 =>
--#line  2386

          sched_params_ref:=new Scheduling_Parameters.fixed_priority_policy;
          Preassigned_Field_Present:=False;


when  434 =>
--#line  2409

          Preassigned_Field_Present:=True;
          if sched_params_ref.all in Scheduling_Parameters.interrupt_fp_policy
          then
             Scheduling_Parameters.set_preassigned
               (Scheduling_Parameters.Fixed_Priority_Parameters'Class
                    (Sched_params_ref.all), True);
             if not YYVal.flag then
                User_Defined_Errors.Parser_Error
                  ("Preassigned field in Interrupt Scheduler cannot be 'No'");
             end if;
          else
             Scheduling_Parameters.set_preassigned
               (Scheduling_Parameters.Fixed_Priority_Parameters'Class
                    (Sched_params_ref.all), YYVal.flag);
          end if;


when  435 =>
--#line  2429

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Priority should be integer value");
        end if;
        begin
           Scheduling_Parameters.set_the_priority
             (Scheduling_Parameters.Fixed_Priority_Parameters'Class
                    (Sched_params_ref.all),
              MAST.Priority(YYval.num));
           if not Preassigned_Field_Present then
              Scheduling_Parameters.set_preassigned
                (Scheduling_Parameters.Fixed_Priority_Parameters'Class
                     (Sched_params_ref.all), True);
           end if;
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority value out of range");
        end;


when  436 =>
--#line  2453

          sched_params_ref:=
               new Scheduling_Parameters.non_preemptible_fp_policy;
          Preassigned_Field_Present:=False;


when  445 =>
--#line  2477

          sched_params_ref:=
               new Scheduling_Parameters.interrupt_fp_policy;
          Preassigned_Field_Present:=False;
          Scheduling_Parameters.set_preassigned
             (Scheduling_Parameters.Fixed_Priority_Parameters'Class
                  (Sched_params_ref.all), True);


when  454 =>
--#line  2504

          sched_params_ref:=new scheduling_Parameters.polling_policy;
          Preassigned_Field_Present:=False;


when  465 =>
--#line  2527

        Scheduling_Parameters.set_polling_period
             (Scheduling_Parameters.Polling_policy'Class
                    (Sched_params_ref.all),
              MAST.Time(YYval.float_num));


when  466 =>
--#line  2536

        Scheduling_Parameters.set_polling_worst_overhead
             (Scheduling_Parameters.Polling_policy'Class
                    (Sched_params_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));


when  467 =>
--#line  2545

        Scheduling_Parameters.set_polling_best_overhead
             (Scheduling_Parameters.Polling_policy'Class
                    (Sched_params_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));


when  468 =>
--#line  2554

        Scheduling_Parameters.set_polling_avg_overhead
             (Scheduling_Parameters.Polling_policy'Class
                    (Sched_params_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));


when  469 =>
--#line  2563

          sched_params_ref:=new scheduling_parameters.sporadic_server_policy;
          Preassigned_Field_Present:=False;


when  480 =>
--#line  2587

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Priority should be integer value");
        end if;
        begin
           Scheduling_Parameters.set_the_priority
             (Scheduling_Parameters.sporadic_server_policy'Class
                    (Sched_params_ref.all),
              MAST.Priority(YYval.num));
           if not Preassigned_Field_Present then
              Scheduling_Parameters.set_preassigned
                (Scheduling_Parameters.Fixed_Priority_Parameters'Class
                     (Sched_params_ref.all), True);
           end if;
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority value out of range");
        end;


when  481 =>
--#line  2611

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Priority should be integer value");
        end if;
        begin
           Scheduling_Parameters.set_background_priority
             (Scheduling_Parameters.sporadic_server_policy'Class
                    (Sched_params_ref.all),
              MAST.Priority(YYval.num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority value out of range");
        end;


when  482 =>
--#line  2630

        Scheduling_Parameters.set_initial_capacity
             (Scheduling_Parameters.sporadic_server_policy'Class
                    (Sched_params_ref.all),
              MAST.Time(YYval.float_num));


when  483 =>
--#line  2639

        Scheduling_Parameters.set_replenishment_period
             (Scheduling_Parameters.sporadic_server_policy'Class
                    (Sched_params_ref.all),
              MAST.Time(YYval.float_num));


when  484 =>
--#line  2648

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Max pending replenishments should be integer value");
        end if;
        Scheduling_Parameters.set_max_pending_replenishments
             (Scheduling_Parameters.sporadic_server_policy'Class
                    (Sched_params_ref.all),
              YYval.num);


when  485 =>
--#line  2661

          sched_params_ref:=new Scheduling_Parameters.edf_policy;
          Preassigned_Field_Present:=False;


when  494 =>
--#line  2684

          Preassigned_Field_Present:=True;
          Scheduling_Parameters.set_preassigned
               (Scheduling_Parameters.Edf_Policy'Class
                    (Sched_params_ref.all), YYVal.flag);


when  495 =>
--#line  2693

           Scheduling_Parameters.set_deadline
             (Scheduling_Parameters.EDF_Policy'Class
                    (Sched_params_ref.all),
              MAST.Time(YYval.Float_num));
           if not Preassigned_Field_Present then
              Scheduling_Parameters.set_preassigned
                (Scheduling_Parameters.EDF_Policy'Class
                     (Sched_params_ref.all), True);
           end if;


when  498 =>
--#line  2717

          overridden_sched_params_ref:=
              new Scheduling_Parameters.Overridden_FP_Parameters;


when  501 =>
--#line  2730

          overridden_sched_params_ref:=
              new Scheduling_Parameters.Overridden_Permanent_FP_Parameters;


when  504 =>
--#line  2742

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Priority should be integer value");
        end if;
        begin
           Scheduling_Parameters.set_the_priority
             (Scheduling_Parameters.Overridden_FP_Parameters'Class
                    (Overridden_Sched_params_ref.all),
              MAST.Priority(YYval.num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority value out of range");
        end;


when  506 =>
--#line  2769

          synch_params_ref:=new Synchronization_Parameters.SRP_Parameters;
          Preassigned_Field_Present:=False;


when  515 =>
--#line  2792

          Preassigned_Field_Present:=True;
          Synchronization_Parameters.set_preassigned
               (Synchronization_Parameters.SRP_Parameters'Class
                    (Synch_params_ref.all), YYVal.flag);


when  516 =>
--#line  2801

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Preemption level should be integer value");
        end if;
        begin
           Synchronization_Parameters.set_preemption_level
             (Synchronization_Parameters.SRP_Parameters'Class
                    (Synch_params_ref.all),
              MAST.Preemption_Level(YYval.num));
           if not Preassigned_Field_Present then
              Synchronization_Parameters.set_preassigned
                (Synchronization_Parameters.SRP_Parameters'Class
                     (Synch_params_ref.all), True);
           end if;
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Preemption level value out of range");
        end;


when  517 =>
--#line  2829

          begin
             Transactions.Add_External_Event_Link(Trans_Ref.all,A_Link_Ref);
          exception
            when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("External event already exists");
          end;


when  523 =>
--#line  2853

          evnt_ref:=new Events.Periodic_Event;
          A_Link_Ref:=new Graphs.Links.Regular_Link;
          Graphs.set_event(a_link_ref.all,evnt_ref);


when  531 =>
--#line  2874

        a_name:=symbol_table.item(YYVal.name_index);
        Events.init(Evnt_ref.all,a_name);


when  532 =>
--#line  2881

        Events.set_period
             (Events.Periodic_Event'Class(Evnt_ref.all),
              MAST.Time(YYval.float_num));


when  533 =>
--#line  2889

        Events.set_max_jitter
             (Events.Periodic_Event'Class(Evnt_ref.all),
              MAST.Time(YYval.float_num));


when  534 =>
--#line  2897

        Events.set_phase
             (Events.Periodic_Event'Class(Evnt_ref.all),
              MAST.Absolute_Time(YYval.float_num));


when  535 =>
--#line  2909

          evnt_ref:=new Events.Singular_Event;
          A_Link_Ref:=new Graphs.Links.Regular_Link;
          Graphs.set_event(a_link_ref.all,evnt_ref);


when  541 =>
--#line  2928

        Events.set_phase
             (Events.Singular_Event'Class(Evnt_ref.all),
              MAST.Absolute_Time(YYval.float_num));


when  542 =>
--#line  2940

          evnt_ref:=new Events.Sporadic_Event;
          A_Link_Ref:=new Graphs.Links.Regular_Link;
          Graphs.set_event(a_link_ref.all,evnt_ref);


when  550 =>
--#line  2961

        Events.set_avg_interarrival
             (Events.Aperiodic_Event'Class(Evnt_ref.all),
              MAST.Time(YYval.float_num));


when  551 =>
--#line  2969

        Events.set_distribution
             (Events.Aperiodic_Event'Class(Evnt_ref.all),
              Distribution_Function'Val(YYval.Num));


when  552 =>
--#line  2977

        Events.set_min_interarrival
             (Events.Sporadic_Event'Class(Evnt_ref.all),
              MAST.Time(YYval.float_num));


when  553 =>
--#line  2989

          evnt_ref:=new Events.Unbounded_Event;
          A_Link_Ref:=new Graphs.Links.Regular_Link;
          Graphs.set_event(a_link_ref.all,evnt_ref);


when  560 =>
--#line  3013

          evnt_ref:=new Events.Bursty_Event;
          A_Link_Ref:=new Graphs.Links.Regular_Link;
          Graphs.set_event(a_link_ref.all,evnt_ref);


when  569 =>
--#line  3035

        Events.set_bound_interval
             (Events.Bursty_Event'Class(Evnt_ref.all),
              MAST.Time(YYval.float_num));


when  570 =>
--#line  3043

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Max arrivals should be integer value");
        end if;
        Events.set_max_arrivals
             (Events.Bursty_Event'Class(Evnt_ref.all),
              YYval.num);


when  571 =>
--#line  3060

          trans_ref:=new Transactions.Regular_Transaction;


when  579 =>
--#line  3079

          a_name:=symbol_table.item(YYVal.name_index);
          Transactions.init(trans_ref.all,a_name);
          begin
             Transactions.lists.add
               (trans_ref,mast_system.transactions);
          exception
            when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("Transaction already exists");
          end;


when  589 =>
--#line  3122

          begin
             Transactions.Add_Internal_Event_Link(Trans_Ref.all,A_Link_Ref);
          exception
            when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("Internal event already exists");
          end;


when  592 =>
--#line  3140

          A_Link_Ref:= new Graphs.Links.Regular_Link;


when  593 =>
--#line  3146

          a_name:=symbol_table.item(YYVal.name_index);
          evnt_ref:=new Events.Internal_Event;
          Events.Init(evnt_ref.all,a_name);
          Graphs.set_event(a_link_ref.all,evnt_ref);


when  596 =>
--#line  3159

        Graphs.Links.set_link_timing_requirements
             (Graphs.Links.Regular_Link(a_link_ref.all),
              timing_reqs_ref);


when  597 =>
--#line  3171

          begin
            Transactions.Add_Event_Handler(Trans_Ref.all,An_Event_Handler_Ref);
          exception
            when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("Event handler already exists");
          end;


when  609 =>
--#line  3201

          An_Event_Handler_Ref:= new Graphs.event_handlers.Activity;


when  616 =>
--#line  3217

          a_name:=symbol_table.item(YYVal.name_index);
          begin
                  A_Link_Ref:=Transactions.Find_Any_Link
                     (a_name,Trans_ref.all);
                  Graphs.Set_Output_Event_Handler
                      (a_link_ref.all, An_Event_Handler_Ref);
                  Graphs.Event_Handlers.Set_Input_Link
                      (Graphs.Event_Handlers.Simple_Event_Handler
                         (an_event_handler_ref.all),
                       A_Link_Ref);
          exception
                  when Transactions.Link_not_found =>
                     declare
                        Lnk_Ref : Graphs.Link_Ref:=
                                 new Graphs.Links.Regular_Link;
                        Evnt_Ref : Events.Event_Ref:=
                                 new Events.Internal_Event;
                     begin
                        Events.Init(Evnt_Ref.all,A_Name);
                        Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
                        Graphs.Set_Output_Event_Handler
                          (Lnk_ref.all, An_Event_Handler_Ref);
                        Graphs.Event_Handlers.Set_Input_Link
                          (Graphs.Event_Handlers.Simple_Event_Handler
                             (an_event_handler_ref.all),Lnk_Ref);
                     end;
                  when Graphs.Invalid_Link_Type =>
                     User_Defined_Errors.Parser_Error
                         ("Invalid event type for event_handler input");
          end;


when  617 =>
--#line  3252

          a_name:=symbol_table.item(YYVal.name_index);
          begin
                  A_link_ref:=Transactions.Find_Any_Link
                     (a_name,Trans_ref.all);
                  Graphs.Set_Input_Event_Handler
                      (a_link_ref.all, An_Event_Handler_Ref);
                  Graphs.Event_Handlers.Set_Output_Link
                      (Graphs.Event_Handlers.Simple_Event_Handler
                          (an_event_handler_ref.all),
                       A_Link_Ref);
          exception
               when Transactions.Link_Not_Found =>
                     declare
                        Lnk_Ref : Graphs.Link_Ref:=
                                 new Graphs.Links.Regular_Link;
                        Evnt_Ref : Events.Event_Ref:=
                                 new Events.Internal_Event;
                     begin
                        Events.Init(Evnt_Ref.all,A_Name);
                        Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
                        Graphs.Set_Input_Event_Handler
                          (Lnk_ref.all, An_Event_Handler_Ref);
                        Graphs.Event_Handlers.Set_Output_Link
                          (Graphs.Event_Handlers.Simple_Event_Handler
                             (an_event_handler_ref.all),Lnk_Ref);
                     end;
               when Graphs.Invalid_Link_Type =>
                  User_Defined_Errors.Parser_Error
                     ("Invalid event type for event_handler output");
          end;


when  618 =>
--#line  3287

          a_name:=symbol_table.item(YYVal.name_index);
          Op_Index:=Operations.Lists.Find
              (a_name,MAST_System.Operations);
          if Op_Index=Operations.Lists.Null_Index then
             declare
                 Op_Ref : Operations.Operation_ref:=
                             new Operations.Simple_Operation;
             begin
                 Operations.Init(Op_Ref.all,A_Name);
                 Graphs.Event_Handlers.Set_Activity_Operation
                     (Graphs.Event_Handlers.Activity(an_event_handler_ref.all),
                      Op_Ref);
             end;
          else
              Graphs.Event_Handlers.Set_Activity_Operation
                  (Graphs.Event_Handlers.Activity(an_event_handler_ref.all),
                   Operations.Lists.Item(Op_Index,MAST_System.Operations));
          end if;


when  619 =>
--#line  3310

          a_name:=symbol_table.item(YYVal.name_index);
          Srvr_Index:=Scheduling_Servers.Lists.Find
              (a_name,MAST_System.scheduling_servers);
          if Srvr_Index=Scheduling_Servers.Lists.Null_Index then
             declare
                 Srvr_Ref : Scheduling_Servers.Scheduling_Server_ref:=
                             new Scheduling_Servers.Scheduling_Server;
             begin
                 Scheduling_Servers.Init(Srvr_Ref.all,A_Name);
                 Graphs.Event_Handlers.Set_Activity_Server
                     (Graphs.Event_Handlers.Activity(an_event_handler_ref.all),
                      Srvr_Ref);
             end;
          else
              Graphs.Event_Handlers.Set_Activity_Server
                  (Graphs.Event_Handlers.Activity(an_event_handler_ref.all),
                   scheduling_servers.Lists.Item
                     (Srvr_Index,MAST_System.scheduling_Servers));
          end if;


when  621 =>
--#line  3341

          An_Event_Handler_Ref:=
              new Graphs.event_handlers.system_Timed_Activity;


when  623 =>
--#line  3354

          An_Event_Handler_Ref:= new Graphs.Event_Handlers.concentrator;


when  631 =>
--#line  3376

          a_name:=symbol_table.item(YYVal.name_index);
          begin
                  A_link_Ref:=Transactions.Find_Any_Link
                     (a_name,Trans_ref.all);
                  Graphs.Set_Output_Event_Handler
                      (a_link_ref.all, An_Event_Handler_Ref);
                  Graphs.Event_Handlers.Add_Input_Link
                      (Graphs.Event_Handlers.Input_Event_Handler
                         (an_event_handler_ref.all),
                       A_Link_Ref);
          exception
               when Transactions.Link_Not_Found =>
                  declare
                        Lnk_Ref : Graphs.Link_Ref:=
                                 new Graphs.Links.Regular_Link;
                        Evnt_Ref : Events.Event_Ref:=
                                 new Events.Internal_Event;
                     begin
                        Events.Init(Evnt_Ref.all,A_Name);
                        Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
                        Graphs.Set_Output_Event_Handler
                          (Lnk_ref.all, An_Event_Handler_Ref);
                        Graphs.Event_Handlers.Add_Input_Link
                          (Graphs.Event_Handlers.Input_Event_Handler
                             (an_event_handler_ref.all),Lnk_Ref);
                     end;
               when Graphs.Invalid_Link_Type =>
                  User_Defined_Errors.Parser_Error
                      ("Invalid event type for event_handler output");
               when List_Exceptions.Already_Exists =>
                  User_Defined_Errors.Parser_Error
                      ("Event already exists");
          end;


when  632 =>
--#line  3414

          a_name:=symbol_table.item(YYVal.name_index);
          begin
                  A_Link_Ref:=Transactions.Find_Any_Link
                     (a_name,Trans_ref.all);
                  Graphs.Set_Input_Event_Handler
                      (a_link_ref.all, An_Event_Handler_Ref);
                  Graphs.Event_Handlers.Set_Output_Link
                      (Graphs.Event_Handlers.Input_Event_Handler
                           (an_event_handler_ref.all),
                       A_Link_Ref);
          exception
               when Transactions.Link_Not_Found =>
                  declare
                        Lnk_Ref : Graphs.Link_Ref:=
                                 new Graphs.Links.Regular_Link;
                        Evnt_Ref : Events.Event_Ref:=
                                 new Events.Internal_Event;
                     begin
                        Events.Init(Evnt_Ref.all,A_Name);
                        Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
                        Graphs.Set_Input_Event_Handler
                          (Lnk_ref.all, An_Event_Handler_Ref);
                        Graphs.Event_Handlers.Set_Output_Link
                          (Graphs.Event_Handlers.Input_Event_Handler
                             (an_event_handler_ref.all),Lnk_Ref);
                     end;
               when Graphs.Invalid_Link_Type =>
                  User_Defined_Errors.Parser_Error
                      ("Invalid event type for event_handler output");
          end;


when  634 =>
--#line  3455

          An_Event_Handler_Ref:= new Graphs.Event_Handlers.barrier;


when  636 =>
--#line  3468

          An_Event_Handler_Ref:= new Graphs.Event_Handlers.delivery_server;


when  641 =>
--#line  3482

        Graphs.Event_Handlers.set_policy
             (Graphs.Event_Handlers.delivery_server(An_Event_Handler_ref.all),
              mast.Delivery_policy'Val(YYval.Num));


when  649 =>
--#line  3506

          a_name:=symbol_table.item(YYVal.name_index);
          begin
                  A_Link_Ref:=Transactions.Find_Any_Link
                     (a_name,Trans_ref.all);
                  Graphs.Set_input_Event_Handler
                      (a_link_ref.all, An_Event_Handler_Ref);
                  Graphs.Event_Handlers.Add_output_link
                      (Graphs.Event_Handlers.output_Event_Handler
                           (an_event_handler_ref.all),
                       A_Link_Ref);
          exception
               when Transactions.Link_Not_Found =>
                  declare
                        Lnk_Ref : Graphs.Link_Ref:=
                                 new Graphs.Links.Regular_Link;
                        Evnt_Ref : Events.Event_Ref:=
                                 new Events.Internal_Event;
                     begin
                        Events.Init(Evnt_Ref.all,A_Name);
                        Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
                        Graphs.Set_Input_Event_Handler
                          (Lnk_ref.all, An_Event_Handler_Ref);
                        Graphs.Event_Handlers.Add_Output_Link
                          (Graphs.Event_Handlers.Output_Event_Handler
                             (an_event_handler_ref.all),Lnk_Ref);
                     end;
               when Graphs.Invalid_Link_Type =>
                  User_Defined_Errors.Parser_Error
                      ("Invalid event type for event_handler output");
               when List_Exceptions.Already_Exists =>
                  User_Defined_Errors.Parser_Error
                      ("Event already exists");
          end;


when  650 =>
--#line  3544

          a_name:=symbol_table.item(YYVal.name_index);
          begin
                  A_Link_Ref:=Transactions.Find_Any_Link
                      (a_name,Trans_ref.all);
                  Graphs.Set_output_Event_Handler
                      (a_link_ref.all, An_Event_Handler_Ref);
                  Graphs.Event_Handlers.Set_input_Link
                      (Graphs.Event_Handlers.output_Event_Handler
                          (an_event_handler_ref.all),
                       A_Link_Ref);
          exception
               when Transactions.Link_Not_Found =>
                  declare
                        Lnk_Ref : Graphs.Link_Ref:=
                                 new Graphs.Links.Regular_Link;
                        Evnt_Ref : Events.Event_Ref:=
                                 new Events.Internal_Event;
                     begin
                        Events.Init(Evnt_Ref.all,A_Name);
                        Graphs.Set_Event(Lnk_Ref.all,Evnt_Ref);
                        Graphs.Set_Output_Event_Handler
                          (Lnk_ref.all, An_Event_Handler_Ref);
                        Graphs.Event_Handlers.set_Input_Link
                          (Graphs.Event_Handlers.Output_Event_Handler
                             (an_event_handler_ref.all),Lnk_Ref);
                     end;
               when Graphs.Invalid_Link_Type =>
                  User_Defined_Errors.Parser_Error
                      ("Invalid event type for event_handler output");
          end;


when  652 =>
--#line  3586

          An_Event_Handler_Ref:= new Graphs.Event_Handlers.query_server;


when  657 =>
--#line  3600

        Graphs.Event_Handlers.set_policy
             (Graphs.Event_Handlers.query_server(An_Event_Handler_ref.all),
              Mast.Request_policy'Val(YYval.Num));


when  659 =>
--#line  3614

          An_Event_Handler_Ref:= new Graphs.Event_Handlers.multicast;


when  661 =>
--#line  3627

          An_Event_Handler_Ref:= new Graphs.Event_Handlers.Rate_Divisor;


when  667 =>
--#line  3642

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Rate factor should be integer value");
        end if;
        Graphs.Event_Handlers.set_rate_factor
             (Graphs.Event_Handlers.rate_divisor(an_event_handler_ref.all),
              YYVal.Num);


when  669 =>
--#line  3661

          An_Event_Handler_Ref:= new Graphs.Event_Handlers.Delay_Event_Handler;


when  676 =>
--#line  3677

        Graphs.Event_Handlers.set_delay_max_interval
             (Graphs.Event_Handlers.delay_Event_Handler
                  (an_event_handler_ref.all),
              MAST.Time(YYVal.float_Num));


when  677 =>
--#line  3686

        Graphs.Event_Handlers.set_delay_min_interval
             (Graphs.Event_Handlers.delay_Event_Handler
                   (an_event_handler_ref.all),
              MAST.Time(YYVal.float_Num));


when  679 =>
--#line  3702

          An_Event_Handler_Ref:= new
               Graphs.Event_Handlers.Offset_Event_Handler;


when  687 =>
--#line  3720

         begin
              a_name:=symbol_table.item(YYVal.name_index);
              Evnt_Ref:=Transactions.Find_Any_Event (A_name,Trans_Ref.all);
              Graphs.Event_Handlers.Set_Referenced_Event
                  (Graphs.Event_Handlers.Offset_Event_Handler
                     (an_event_handler_ref.all),Evnt_Ref);
         exception
             when Transactions.Event_Not_Found =>
                User_Defined_Errors.Parser_Error
                    ("Event name "&To_String(a_name)&" not found");
         end;


when  696 =>
--#line  3751

          timing_reqs_ref:=new Mast.Timing_requirements.hard_global_deadline;


when  703 =>
--#line  3769

        Mast.Timing_requirements.set_the_deadline
             (Mast.Timing_requirements.deadline'Class
                    (Timing_reqs_ref.all),
              MAST.Time(YYval.float_num));


when  704 =>
--#line  3778

         begin
             a_name:=symbol_table.item(YYVal.name_index);
             Evnt_Ref:=Transactions.Find_Any_Event (A_name,Trans_Ref.all);
             Mast.Timing_requirements.set_event
                  (Mast.Timing_requirements.global_deadline
                         (Timing_reqs_ref.all),evnt_ref);
         exception
             when Transactions.Event_Not_Found =>
                  declare
                        Evnt_Ref : Events.Event_Ref:=
                                 new Events.Internal_Event;
                  begin
                        Events.Init(Evnt_Ref.all,A_Name);
                        Mast.Timing_requirements.set_event
                          (Mast.Timing_requirements.global_deadline
                             (Timing_reqs_ref.all),evnt_ref);
                  end;
         end;


when  705 =>
--#line  3801

          timing_reqs_ref:=new Mast.Timing_requirements.soft_global_deadline;


when  708 =>
--#line  3811

          timing_reqs_ref:=new Mast.Timing_requirements.hard_local_deadline;


when  711 =>
--#line  3821

          timing_reqs_ref:=new Mast.Timing_requirements.soft_local_deadline;


when  714 =>
--#line  3831

          timing_reqs_ref:=new Mast.Timing_requirements.global_max_miss_ratio;


when  722 =>
--#line  3850

        begin
           Mast.Timing_requirements.set_ratio
                (Mast.Timing_requirements.global_max_miss_ratio'Class
                       (Timing_reqs_ref.all),
                 MAST.Percentage(YYval.float_num));
        exception
           when Constraint_Error =>
               User_Defined_Errors.Parser_Error
                    ("Bad Percentage");
        end;


when  723 =>
--#line  3865

          timing_reqs_ref:=new Mast.Timing_requirements.local_max_miss_ratio;


when  730 =>
--#line  3883

        begin
           Mast.Timing_requirements.set_ratio
                (Mast.Timing_requirements.local_max_miss_ratio'Class
                       (Timing_reqs_ref.all),
                 MAST.Percentage(YYval.float_num));
        exception
           when Constraint_Error =>
               User_Defined_Errors.Parser_Error
                    ("Bad Percentage");
        end;


when  731 =>
--#line  3898

          timing_reqs_ref:=new Mast.Timing_requirements.
                                 max_output_jitter_req;


when  738 =>
--#line  3917

         begin
             a_name:=symbol_table.item(YYVal.name_index);
             Evnt_Ref:=Transactions.Find_Any_Event (A_name,Trans_Ref.all);
             Mast.Timing_requirements.set_event
                  (Mast.Timing_requirements.max_output_jitter_req
                         (Timing_reqs_ref.all),evnt_ref);
         exception
             when Transactions.Event_Not_Found =>
                  declare
                        Evnt_Ref : Events.Event_Ref:=
                                 new Events.Internal_Event;
                  begin
                        Events.Init(Evnt_Ref.all,A_Name);
                        Mast.Timing_requirements.set_event
                          (Mast.Timing_requirements.max_output_jitter_req
                             (Timing_reqs_ref.all),evnt_ref);
                  end;
         end;


when  739 =>
--#line  3940

        Mast.Timing_requirements.set_max_output_jitter
             (Mast.Timing_requirements.max_output_jitter_req'Class
                    (Timing_reqs_ref.all),
              MAST.Time(YYval.float_num));


when  740 =>
--#line  3953

          sec_timing_reqs_ref:=new Mast.Timing_Requirements.
                                 Composite_Timing_Req;


when  741 =>
--#line  3958

           Timing_reqs_Ref:=Sec_Timing_Reqs_Ref;


when  746 =>
--#line  3975

          Mast.Timing_Requirements.Add_Requirement
                  (Mast.Timing_Requirements.Composite_Timing_Req
                        (Sec_Timing_Reqs_ref.all),
                   Mast.Timing_requirements.simple_timing_requirement_ref
                        (Timing_Reqs_Ref));


when  757 =>
--#line  4005

          srvr_ref:=new Scheduling_Servers.Scheduling_Server;


when  759 =>
--#line  4012

          srvr_ref:=new Scheduling_Servers.Scheduling_Server;


when  767 =>
--#line  4031

          a_name:=symbol_table.item(YYVal.name_index);
          scheduling_Servers.init(srvr_ref.all,a_name);
          begin
             Scheduling_Servers.lists.add
               (srvr_ref,mast_system.scheduling_servers);
          exception
            when List_Exceptions.Already_Exists =>
             User_Defined_Errors.Parser_Error
                 ("Scheduling server already exists");
          end;


when  768 =>
--#line  4046

          a_name:=symbol_table.item(YYVal.name_index);
          Scheduler_Index:=Schedulers.Lists.Find
              (a_name,MAST_System.Schedulers);
          if Scheduler_Index=Schedulers.Lists.Null_Index then
             declare
                 sched_ref : Schedulers.Scheduler_ref:=
                    new Schedulers.Primary.Primary_scheduler;
             begin
                 Schedulers.Init(sched_ref.all,a_name);
                 Scheduling_servers.Set_server_scheduler
                    (srvr_ref.all,sched_ref);
              end;
          else
             declare
                 sched_ref : Schedulers.Scheduler_ref;
             begin
                 sched_ref:=Schedulers.Lists.Item
                      (Scheduler_index,
                       MAST_System.Schedulers);
                 if sched_ref.all in Schedulers.Primary.Primary_Scheduler'class
                 then
                     Scheduling_servers.Set_server_scheduler
                        (srvr_ref.all,sched_ref);
                 else
                     User_Defined_Errors.Parser_Error
                        ("Processing resource name "&To_String(a_name)&
                          " does not correspond to a primary scheduler");
                 end if;
              end;
          end if;


when  769 =>
--#line  4081

          scheduling_servers.set_server_sched_parameters
            (srvr_ref.all,Sched_params_ref);


when  770 =>
--#line  4088

          scheduling_servers.set_server_synch_parameters
            (srvr_ref.all,Synch_params_ref);


when  777 =>
--#line  4107

          a_name:=symbol_table.item(YYVal.name_index);
          Scheduler_Index:=Schedulers.Lists.Find
              (a_name,MAST_System.Schedulers);
          if Scheduler_Index=Schedulers.Lists.Null_Index then
             declare
                 sched_ref : Schedulers.Scheduler_ref:=
                    new Schedulers.Primary.Primary_scheduler;
             begin
                 Schedulers.Init(sched_ref.all,a_name);
                 Scheduling_servers.Set_server_scheduler
                    (srvr_ref.all,sched_ref);
              end;
          else
             declare
                 sched_ref : Schedulers.Scheduler_ref;
             begin
                 sched_ref:=Schedulers.Lists.Item
                      (Scheduler_index,
                       MAST_System.Schedulers);
                 Scheduling_servers.Set_server_scheduler
                        (srvr_ref.all,sched_ref);
              end;
          end if;


                    when others => null;
                end case;

-- UMASS CODES :
--   Corresponding to the codes above.
              exception
                when others =>
                   if yy_error_report.total_errors > 0 then
                     yyerror_recovery.valuing := False;
                     -- We no longer want to invoke any semantic action.
                   else
                     -- this exception is not caused by syntax error,
                     -- so we reraise anyway.
                     yy_error_report.Finish_Output;
                     raise;
                   end if;
              end;
            end if;
-- END OF UMASS CODES.

            -- Pop RHS states and goto next state
            yy.tos      := yy.tos - rule_length(yy.rule_id) + 1;
            if yy.tos > yy.stack_size then
                text_io.put_line(" Stack size exceeded on state_stack");
-- UMASS CODES :
                yy_error_report.put_line(" Stack size exceeded on state_stack");
                yyerror_recovery.finale;
-- END OF UMASS CODES.
                raise yy_Tokens.syntax_error;
            end if;
            yy.state_stack(yy.tos) := goto_state(yy.state_stack(yy.tos-1) ,
                                 get_lhs_rule(yy.rule_id));

-- UMASS CODES :
--   Set value stack only if valuing is True.
            if yyerror_recovery.valuing then
-- END OF UMASS CODES.
              yy.value_stack(yy.tos) := yyval;
-- UMASS CODES :
            end if;
-- END OF UMASS CODES.

            if yy.debug then
                reduce_debug(yy.rule_id,
                    goto_state(yy.state_stack(yy.tos - 1),
                               get_lhs_rule(yy.rule_id)));
            end if;

        end if;

-- UMASS CODES :
--   If the error flag is set to zero at current token,
--   we flag current token out.
        if yyerror_recovery.previous_error_flag > 0 and then
           yy.error_flag = 0 then
          yyerror_recovery.flag_token ( error => False );
        end if;

--   save the action made and error flag.
        yyerror_recovery.previous_action := yy.action;
        yyerror_recovery.previous_error_flag := yy.error_flag;
-- END OF UMASS CODES.

    end loop;

-- UMASS CODES :
    finale;
-- END OF UMASS CODES.

end yyparse;

begin
     Mast_Lex_dfa.yy_init:=true;
     Mast_Lex_dfa.yy_start:=0;
     Mast_Lex_IO.Saved_Tok_Line1:=null;
     Mast_Lex_IO.Saved_Tok_Line2:=null;
     Mast_Lex_IO.Line_Number_Of_Saved_Tok_Line1:=0;
     Mast_Lex_IO.Line_Number_Of_Saved_Tok_Line2:=0;
     Mast_Lex_IO.tok_begin_line:=1;
     Mast_Lex_IO.tok_end_line:=1;
     Mast_Lex_IO.tok_begin_col:=0;
     Mast_Lex_IO.tok_end_col:=0;
     Mast_Lex_IO.token_at_end_of_line:=False;
     Mast_Parser_Error_Report.Total_Errors:=0;
     Mast_Parser_Error_Report.Total_Warnings:=0;
     Mast_System:=Null_System;
     YYparse;
end MAST_Parser;



