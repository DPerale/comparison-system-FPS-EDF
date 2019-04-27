with MAST, MAST.Operations, MAST.Shared_Resources, 
  MAST.Processing_Resources, MAST.Processing_Resources.Processor,
  MAST.Scheduling_Servers, MAST.IO,
  MAST.Transactions, 
  MAST.Systems, 
  MAST.Scheduling_Parameters, MAST.Synchronization_Parameters,
  MAST.Results,
  MAST.Events, MAST.Graphs, MAST.Graphs.Links,
  List_Exceptions;
with Symbol_Table; use Symbol_Table;
with MAST_Results_lex; Use MAST_REsults_Lex;
with Var_Strings; use Var_Strings;
with MAST_Results_Parser_Tokens, MAST_Results_Parser_Shift_Reduce,
  MAST_Results_Parser_Goto,MAST_Results_Parser_Error_Report,
  MAST_Results_Lex_IO, MAST_Results_Lex_Dfa;
with Text_IO; use Text_IO;
use MAST_Results_Parser_Tokens, MAST_Results_Parser_Shift_Reduce,
  MAST_Results_Parser_Goto,MAST_Results_Lex_IO;
use MAST;
procedure MAST_Results_Parser (MAST_System : in out MAST.Systems.System) is

      procedure YYError (S : in String) is  
      begin
          MAST_Results_Parser_Error_Report.Report_Continuable_Error
                 (YY_Line_Number, YY_Begin_Column, YY_End_Column, S, True);
      end YYError;

      PR_Ref                : Processing_Resources.Processing_Resource_Ref;
      SR_Ref                : Shared_Resources.Shared_Resource_Ref; 
      Op_Ref                : Operations.Operation_Ref;
      SS_Ref                : Scheduling_Servers.Scheduling_Server_Ref;
      Sched_Params_Ref      : Mast.Scheduling_Parameters.Sched_Parameters_Ref;
      Synch_Params_Ref      : 
            Mast.Synchronization_Parameters.Synch_Parameters_Ref;
      Tr_Ref                : Transactions.Transaction_Ref;
      The_Event_Ref         : MAST.Events.Event_Ref;
      A_Deadline            : Time;
 
      The_trace_Res : Mast.Results.Trace_Result_Ref;
      The_Slack_Res : Mast.Results.Slack_Result_Ref;
      The_Utilization_res : Mast.Results.Utilization_Result_Ref;
      The_Queue_Size_Res : MAST.results.Queue_Size_Result_Ref;
      The_Ceiling_Res : Mast.results.Ceiling_Result_Ref;
      The_Preemption_Level_Res : Mast.results.Preemption_Level_Result_Ref;
      The_SP_Res : Mast.Results.Sched_Params_Result_Ref;
      The_SynchP_Res : Mast.Results.Synch_Params_Result_Ref;
      The_Timing_Res : Mast.Results.Timing_Result_Ref;
     
      preassigned_field_present : Boolean:=False;

      use type Operations.Lists.Index;
      use type Processing_resources.Lists.Index;
      use type Shared_resources.Lists.Index;
      use type Scheduling_Servers.Lists.Index;

procedure YYParse is

   -- Rename User Defined Packages to Internal Names.
    package yy_goto_tables         renames
      Mast_Results_Parser_Goto;
    package yy_shift_reduce_tables renames
      Mast_Results_Parser_Shift_Reduce;
    package yy_tokens              renames
      Mast_Results_Parser_Tokens;
    -- UMASS CODES :
    package yy_error_report renames
      Mast_Results_Parser_Error_Report;
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

when  18 =>
--#line  163

	null;
      

when  19 =>
--#line  169

        null;
      

when  20 =>
--#line  175

	Mast_System.Generation_Tool:=YYVal.text;
      

when  21 =>
--#line  181

	Mast_System.Generation_Profile:=YYVal.text;
      

when  22 =>
--#line  187

	Mast_System.Generation_Date:=YYVal.Date;
        if not Mast.IO.Is_Date_OK(Mast_System.Generation_Date) then
	    User_Defined_Errors.Parser_Error
                 ("Error in date value");
        end if;
      

when  28 =>
--#line  208

        The_Slack_Res:=new Mast.Results.Slack_Result;
	Systems.Set_Slack_Result(Mast_System,The_Slack_Res);
      

when  29 =>
--#line  213

	Mast.Results.Set_Slack(The_Slack_Res.all,Float(YYVal.Float_Num));
      

when  30 =>
--#line  219

        The_Trace_Res:=new Mast.Results.Trace_Result;
 	Systems.Set_Trace_Result(Mast_System,The_Trace_Res);
      

when  31 =>
--#line  224

	Mast.Results.Set_Pathname(The_Trace_Res.all,To_String(YYVal.Text));
      

when  37 =>
--#line  246

	--find the processing resource
        declare
	  The_Index : Processing_Resources.Lists.Index;
        begin
	  The_Index:=Processing_Resources.Lists.Find
	    (Symbol_Table.Item(YYVal.Name_Index),
             Mast_System.Processing_Resources);
	     Pr_Ref:=Processing_Resources.Lists.Item
		    (The_Index,Mast_System.Processing_Resources);             
          exception
             when List_Exceptions.Invalid_Index =>
                -- create dummy processing resource
	        Pr_Ref:=new Processing_Resources.Processor.Regular_Processor;
                User_Defined_Errors.Parser_Error
                  (To_String("Processing Resource "&
                   Symbol_Table.Item(YYVal.Name_Index)&" not found"));
	  end;
      

when  44 =>
--#line  280

        The_Slack_res:=new Mast.Results.Slack_Result;
	Processing_Resources.Set_Slack_Result(Pr_Ref.all,The_Slack_Res);
      

when  45 =>
--#line  285

	Mast.Results.Set_Slack(The_Slack_Res.all,Float(YYVal.Float_Num));
      

when  46 =>
--#line  291

          The_Utilization_Res:=new Mast.Results.Detailed_Utilization_Result;
          Processing_Resources.Set_Utilization_result
            (Pr_Ref.all,The_Utilization_Res);
      

when  55 =>
--#line  311

	Mast.Results.Set_Total
          (Mast.Results.Detailed_Utilization_Result(The_Utilization_Res.all),
           Float(YYVal.Float_Num));
      

when  56 =>
--#line  319

	Mast.Results.Set_Application
          (Mast.Results.Detailed_Utilization_Result(The_Utilization_Res.all),
           Float(YYVal.Float_Num));
      

when  57 =>
--#line  327

	Mast.Results.Set_Context_Switch
          (Mast.Results.Detailed_Utilization_Result(The_Utilization_Res.all),
           Float(YYVal.Float_Num));
      

when  58 =>
--#line  335

	Mast.Results.Set_Timer
          (Mast.Results.Detailed_Utilization_Result(The_Utilization_Res.all),
           Float(YYVal.Float_Num));
      

when  59 =>
--#line  343

	Mast.Results.Set_Driver
          (Mast.Results.Detailed_Utilization_Result(The_Utilization_Res.all),
           Float(YYVal.Float_Num));
      

when  60 =>
--#line  352

        The_queue_size_res:=new Mast.Results.Ready_Queue_Size_Result;
	Processing_Resources.Set_Ready_Queue_Size_Result
           (Pr_Ref.all,
            Mast.results.ready_queue_size_result_ref(The_queue_size_Res));
      

when  61 =>
--#line  359

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Max_Num should be integer value");
        end if;
	Mast.Results.Set_Max_Num
           (The_Queue_Size_Res.all,YYVal.Num);
      

when  67 =>
--#line  386

	--find the shared resource
        declare
	  The_Index : Shared_Resources.Lists.Index;
        begin
	  The_Index:=Shared_Resources.Lists.Find
	    (Symbol_Table.Item(YYVal.Name_Index),
             Mast_System.Shared_Resources);
	     Sr_Ref:=Shared_Resources.Lists.Item
		    (The_Index,Mast_System.Shared_Resources);             
          exception
             when List_Exceptions.Invalid_Index =>
                -- create dummy shared resource
	        Sr_Ref:=new Shared_Resources.Immediate_Ceiling_Resource;
                User_Defined_Errors.Parser_Error
                  (To_String("Shared Resource "&
                   Symbol_Table.Item(YYVal.Name_Index)&" not found"));
	  end;
      

when  75 =>
--#line  421

        The_Ceiling_Res:=new Mast.Results.Ceiling_Result;
	Shared_Resources.Set_Ceiling_Result(Sr_Ref.all,The_Ceiling_Res);
      

when  76 =>
--#line  426

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Ceiling should be integer value");
        end if;
        begin
           Mast.Results.Set_Ceiling(The_Ceiling_Res.all,Priority(YYVal.Num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority ceiling value out of range");
        end;
      

when  77 =>
--#line  442

        The_Preemption_Level_Res:=new Mast.Results.Preemption_Level_Result;
	Shared_Resources.Set_Preemption_Level_Result
          (Sr_Ref.all,The_Preemption_Level_Res);
      

when  78 =>
--#line  448

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Preemption Level should be integer value");
        end if;
        begin
           Mast.Results.Set_Preemption_Level
              (The_Preemption_Level_Res.all,Mast.Preemption_Level(YYVal.Num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Preemption level value out of range");
        end;
      

when  79 =>
--#line  465

          The_Utilization_Res:=new Mast.Results.Utilization_Result;
          Shared_Resources.Set_Utilization_result
            (Sr_Ref.all,The_Utilization_Res);
      

when  80 =>
--#line  471

	Mast.Results.Set_Total
          (The_Utilization_Res.all,Float(YYVal.Float_Num));
      

when  81 =>
--#line  478

        The_queue_size_res:=new Mast.Results.Queue_Size_Result;
	Shared_Resources.Set_Queue_Size_Result
           (Sr_Ref.all,The_queue_size_Res);
      

when  82 =>
--#line  484

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Max_Num should be integer value");
        end if;
	Mast.Results.Set_Max_Num
           (The_Queue_Size_Res.all,YYVal.Num);
      

when  88 =>
--#line  511

	--find the operation
        declare
	  The_Index : Operations.Lists.Index;
        begin
	  The_Index:=Operations.Lists.Find
	    (Symbol_Table.Item(YYVal.Name_Index),
             Mast_System.Operations);
	     Op_Ref:=Operations.Lists.Item
		    (The_Index,Mast_System.Operations);             
          exception
             when List_Exceptions.Invalid_Index =>
                -- create dummy operation
	        Op_Ref:=new Operations.Simple_Operation;
                User_Defined_Errors.Parser_Error
                  (To_String("Operation "&
                   Symbol_Table.Item(YYVal.Name_Index)&" not found"));
	  end;
      

when  93 =>
--#line  543

        The_Slack_Res:=new Mast.Results.Slack_Result;
	Operations.Set_Slack_Result(Op_Ref.all,The_Slack_Res);
      

when  94 =>
--#line  548

	Mast.Results.Set_Slack(The_Slack_Res.all,Float(YYVal.Float_Num));
      

when  101 =>
--#line  568

          sched_params_ref:=
              new Mast.Scheduling_Parameters.fixed_priority_policy;
          Preassigned_Field_Present:=False;
      

when  110 =>
--#line  592

          Preassigned_Field_Present:=True;
          if sched_params_ref.all in 
             Mast.Scheduling_Parameters.interrupt_fp_policy
          then          
             Mast.Scheduling_Parameters.set_preassigned
               (Mast.Scheduling_Parameters.Fixed_Priority_Parameters'Class
                    (Sched_params_ref.all), True);
             if not YYVal.flag then
                User_Defined_Errors.Parser_Error
                  ("Preassigned field in Interrupt Scheduler cannot be 'No'");
	     end if;
          else
             Mast.Scheduling_Parameters.set_preassigned
               (Mast.Scheduling_Parameters.Fixed_Priority_Parameters'Class
                    (Sched_params_ref.all), YYVal.flag);
          end if;
      

when  111 =>
--#line  613

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Priority should be integer value");
        end if;
        begin
           Mast.Scheduling_Parameters.set_the_priority
             (Mast.Scheduling_Parameters.Fixed_Priority_Parameters'Class
                    (Sched_params_ref.all),
              MAST.Priority(YYval.num));
           if not Preassigned_Field_Present then
              Mast.Scheduling_Parameters.set_preassigned
                (Mast.Scheduling_Parameters.Fixed_Priority_Parameters'Class
                     (Sched_params_ref.all), True);
           end if;
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority value out of range");
        end;
      

when  112 =>
--#line  637

          sched_params_ref:=
               new Mast.Scheduling_Parameters.non_preemptible_fp_policy;
          Preassigned_Field_Present:=False;
      

when  121 =>
--#line  661

          sched_params_ref:=
               new Mast.Scheduling_Parameters.interrupt_fp_policy;
          Preassigned_Field_Present:=False;
          Mast.Scheduling_Parameters.set_preassigned
             (Mast.Scheduling_Parameters.Fixed_Priority_Parameters'Class
                  (Sched_params_ref.all), True);
      

when  130 =>
--#line  688

          sched_params_ref:=new Mast.scheduling_Parameters.polling_policy;
          Preassigned_Field_Present:=False;
      

when  141 =>
--#line  711

        Mast.Scheduling_Parameters.set_polling_period
             (Mast.Scheduling_Parameters.Polling_policy'Class
                    (Sched_params_ref.all),
              MAST.Time(YYval.float_num));
      

when  142 =>
--#line  720

        Mast.Scheduling_Parameters.set_polling_worst_overhead
             (Mast.Scheduling_Parameters.Polling_policy'Class
                    (Sched_params_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));
      

when  143 =>
--#line  729

        Mast.Scheduling_Parameters.set_polling_best_overhead
             (Mast.Scheduling_Parameters.Polling_policy'Class
                    (Sched_params_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));
      

when  144 =>
--#line  738

        Mast.Scheduling_Parameters.set_polling_avg_overhead
             (Mast.Scheduling_Parameters.Polling_policy'Class
                    (Sched_params_ref.all),
              MAST.Normalized_Execution_Time(YYval.float_num));
      

when  145 =>
--#line  747

          sched_params_ref:=
             new Mast.scheduling_parameters.sporadic_server_policy;
          Preassigned_Field_Present:=False;
      

when  156 =>
--#line  772

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Priority should be integer value");
        end if;
        begin
           Mast.Scheduling_Parameters.set_the_priority
             (Mast.Scheduling_Parameters.sporadic_server_policy'Class
                    (Sched_params_ref.all),
              MAST.Priority(YYval.num));
           if not Preassigned_Field_Present then
              Mast.Scheduling_Parameters.set_preassigned
                (Mast.Scheduling_Parameters.Fixed_Priority_Parameters'Class
                     (Sched_params_ref.all), True);
           end if;
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority value out of range");
        end;
      

when  157 =>
--#line  796

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Priority should be integer value");
        end if;
        begin
           Mast.Scheduling_Parameters.set_background_priority
             (Mast.Scheduling_Parameters.sporadic_server_policy'Class
                    (Sched_params_ref.all),
              MAST.Priority(YYval.num));
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Priority value out of range");
        end;
      

when  158 =>
--#line  815

        Mast.Scheduling_Parameters.set_initial_capacity
             (Mast.Scheduling_Parameters.sporadic_server_policy'Class
                    (Sched_params_ref.all),
              MAST.Time(YYval.float_num));
      

when  159 =>
--#line  824

        Mast.Scheduling_Parameters.set_replenishment_period
             (Mast.Scheduling_Parameters.sporadic_server_policy'Class
                    (Sched_params_ref.all),
              MAST.Time(YYval.float_num));
      

when  160 =>
--#line  833

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Max pending replenishments should be integer value");
        end if;
        Mast.Scheduling_Parameters.set_max_pending_replenishments
             (Mast.Scheduling_Parameters.sporadic_server_policy'Class
                    (Sched_params_ref.all),
              YYval.num);
      

when  161 =>
--#line  846

          sched_params_ref:=new Mast.Scheduling_Parameters.edf_policy;
          Preassigned_Field_Present:=False;
      

when  170 =>
--#line  869

          Preassigned_Field_Present:=True;
          Mast.Scheduling_Parameters.set_preassigned
               (Mast.Scheduling_Parameters.Edf_Policy'Class
                    (Sched_params_ref.all), YYVal.flag);
      

when  171 =>
--#line  878

           Mast.Scheduling_Parameters.set_deadline
             (Mast.Scheduling_Parameters.EDF_Policy'Class
                    (Sched_params_ref.all),
              MAST.Time(YYval.Float_num));
           if not Preassigned_Field_Present then
              Mast.Scheduling_Parameters.set_preassigned
                (Mast.Scheduling_Parameters.EDF_Policy'Class
                     (Sched_params_ref.all), True);
           end if;
      

when  173 =>
--#line  900

          synch_params_ref:=new Mast.Synchronization_Parameters.SRP_Parameters;
          Preassigned_Field_Present:=False;
      

when  182 =>
--#line  923

          Preassigned_Field_Present:=True;
          Mast.Synchronization_Parameters.set_preassigned
               (Mast.Synchronization_Parameters.SRP_Parameters'Class
                    (Synch_params_ref.all), YYVal.flag);
      

when  183 =>
--#line  932

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Preemption level should be integer value");
        end if;
        begin
           Mast.Synchronization_Parameters.set_preemption_level
             (Mast.Synchronization_Parameters.SRP_Parameters'Class
                    (Synch_params_ref.all),
              MAST.Preemption_Level(YYval.num));
           if not Preassigned_Field_Present then
              Mast.Synchronization_Parameters.set_preassigned
                (Mast.Synchronization_Parameters.SRP_Parameters'Class
                     (Synch_params_ref.all), True);
           end if;
        exception
           when Constraint_Error =>
              User_Defined_Errors.Parser_Error
                 ("Preemption level value out of range");
        end;
      

when  189 =>
--#line  972

	--find the transaction
        declare
	  The_Index : Transactions.Lists.Index;
        begin
	  The_Index:=Transactions.Lists.Find
	    (Symbol_Table.Item(YYVal.Name_Index),
             Mast_System.Transactions);
	     Tr_Ref:=Transactions.Lists.Item
		    (The_Index,Mast_System.Transactions);
          exception
             when List_Exceptions.Invalid_Index =>
                -- create dummy transaction
	        Tr_Ref:=new Transactions.Regular_Transaction;
                User_Defined_Errors.Parser_Error
                  (To_String("Transaction "&
                   Symbol_Table.Item(YYVal.Name_Index)&" not found"));
	  end;
      

when  196 =>
--#line  1006

        The_Slack_res:=new Mast.Results.Slack_Result;
	Transactions.Set_Slack_Result(Tr_Ref.all,The_Slack_Res);
      

when  197 =>
--#line  1011

	Mast.Results.Set_Slack(The_Slack_Res.all,Float(YYVal.Float_Num));
      

when  198 =>
--#line  1017

          The_Timing_Res:=new Mast.Results.Timing_Result;
      

when  210 =>
--#line  1038

        declare
           The_Link : MAST.Graphs.Link_Ref;
        begin
           --find the link
	  The_Link:=Transactions.Find_Internal_Event_Link
	    (Symbol_Table.Item(YYVal.Name_Index),
             Tr_Ref.all);
          MAST.Graphs.Links.Set_Link_Time_Results
              (Mast.Graphs.Links.Regular_Link(The_Link.all),
              The_Timing_Res);
          Mast.Results.Set_Link
             (The_Timing_Res.all,The_Link);
        exception
                -- create dummy link
             when Transactions.Link_Not_Found =>
                User_Defined_Errors.Parser_Error
                  (To_String("Event "&
                   Symbol_Table.Item(YYVal.Name_Index)&
                   " not found in transaction "&
                   Transactions.Name(Tr_Ref)));
        end;
      

when  211 =>
--#line  1064

	Mast.Results.Set_Worst_Local_Response_Time
          (The_Timing_Res.all, Time(YYVal.Float_Num));
      

when  212 =>
--#line  1071

	Mast.Results.Set_Best_Local_Response_Time
          (The_Timing_Res.all, Time(YYVal.Float_Num));
      

when  213 =>
--#line  1078

	Mast.Results.Set_Worst_Blocking_Time
          (The_Timing_Res.all, Time(YYVal.Float_Num));
      

when  214 =>
--#line  1085

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Num_Of_Suspensions should be integer value");
        end if;
	Mast.Results.Set_Num_Of_Suspensions
          (The_Timing_Res.all, YYVal.Num);
      

when  220 =>
--#line  1110

        Mast.Results.set_worst_global_response_time
          (The_Timing_Res.all, The_Event_Ref, MAST.Time(YYval.float_num));
      

when  221 =>
--#line  1117

         declare
            a_name : Var_String;
         begin
             a_name:=symbol_table.item(YYVal.name_index);
             The_Event_Ref:=Transactions.Find_Any_Event (A_name,Tr_Ref.all);
         exception
             when Transactions.Event_Not_Found =>
                User_Defined_Errors.Parser_Error
                    ("Event name "&To_String(a_name)&" not found");
         end;
      

when  227 =>
--#line  1146

        Mast.Results.set_best_global_response_time
          (The_Timing_Res.all, The_Event_Ref, MAST.Time(YYval.float_num));
      

when  233 =>
--#line  1166

        Mast.Results.set_jitter
          (The_Timing_Res.all, The_Event_Ref, MAST.Time(YYval.float_num));
      

when  234 =>
--#line  1174

          The_Timing_Res:=new Mast.Results.Simulation_Timing_Result;
      

when  254 =>
--#line  1203

	Mast.Results.Set_Local_Simulation_Time
          (Mast.Results.Simulation_Timing_Result
            (The_Timing_Res.all), (Time(YYVal.Float_Num),1));
      

when  255 =>
--#line  1211

	Mast.Results.Set_Avg_Blocking_Time
          (Mast.Results.Simulation_Timing_Result
            (The_Timing_Res.all), Time(YYVal.Float_Num));
      

when  256 =>
--#line  1219

	Mast.Results.Set_Max_Preemption_Time
          (Mast.Results.Simulation_Timing_Result
            (The_Timing_Res.all), Time(YYVal.Float_Num));
      

when  257 =>
--#line  1227

	Mast.Results.Set_Suspension_Time
          (Mast.Results.Simulation_Timing_Result
            (The_Timing_Res.all), Time(YYVal.Float_Num));
      

when  258 =>
--#line  1235

        if YYVal.Is_Float then
             User_Defined_Errors.Parser_Error
                 ("Num_Of_Queued_Activations should be integer value");
        end if;
	Mast.Results.Set_Num_Of_Queued_Activations
          (Mast.Results.Simulation_Timing_Result
            (The_Timing_Res.all), YYVal.Num);
      

when  264 =>
--#line  1261

        Mast.Results.Set_global_simulation_time
          (Mast.Results.Simulation_Timing_Result
            (The_Timing_Res.all), The_Event_Ref, 
            (MAST.Time(YYval.float_num),1));
      

when  269 =>
--#line  1281

         A_Deadline:=MAST.Time(YYval.float_num);
      

when  270 =>
--#line  1287

         declare
            The_Ratio : Float;
         begin
            The_Ratio:=Float(YYval.float_num);
            Mast.results.set_local_miss_ratio
             (Mast.Results.Simulation_Timing_Result
               (The_Timing_Res.all), A_Deadline, 
                 (Integer(The_Ratio*1.0E6),1E8));
         end;
      

when  279 =>
--#line  1321

         declare
            The_Ratio : Float;
         begin
            The_Ratio:=Float(YYval.float_num);
            Mast.results.set_global_miss_ratio
             (Mast.Results.Simulation_Timing_Result
               (The_Timing_Res.all), A_Deadline, The_Event_Ref,
                (Integer(The_Ratio*1.0E6),1E8));
         end;
      

when  285 =>
--#line  1351

	--find the scheduling_server
        declare
	  The_Index : Mast.Scheduling_Servers.Lists.Index;
        begin
	  The_Index:=Mast.Scheduling_Servers.Lists.Find
	    (Symbol_Table.Item(YYVal.Name_Index),
             Mast_System.Scheduling_Servers);
	     SS_Ref:=Mast.Scheduling_Servers.Lists.Item
		    (The_Index,Mast_System.Scheduling_Servers);             
          exception
             when List_Exceptions.Invalid_Index =>
                -- create dummy scheduling_server
	        SS_Ref:=new Mast.Scheduling_Servers.Scheduling_Server;
                User_Defined_Errors.Parser_Error
                  (To_String("Scheduling Server "&
                   Symbol_Table.Item(YYVal.Name_Index)&" not found"));
	  end;
      

when  291 =>
--#line  1384

        The_SP_Res:=new Mast.Results.Sched_Params_Result;
	Mast.Scheduling_Servers.Set_Sched_Params_Result(SS_Ref.all,The_SP_Res);
      

when  292 =>
--#line  1389

	Mast.Results.Set_Sched_Params(The_SP_Res.all,Sched_Params_Ref);
      

when  293 =>
--#line  1395

        The_SynchP_Res:=new Mast.Results.Synch_Params_Result;
	Mast.Scheduling_Servers.Set_Synch_Params_Result
           (SS_Ref.all,The_SynchP_Res);
      

when  294 =>
--#line  1401

	Mast.Results.Set_Synch_Params(The_SynchP_Res.all,Synch_Params_Ref);
      

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
     Mast_Results_Lex_dfa.yy_init:=true;
     Mast_Results_Lex_dfa.yy_start:=0;
     Mast_Results_Lex_IO.Saved_Tok_Line1:=null;
     Mast_Results_Lex_IO.Saved_Tok_Line2:=null;
     Mast_Results_Lex_IO.Line_Number_Of_Saved_Tok_Line1:=0;
     Mast_Results_Lex_IO.Line_Number_Of_Saved_Tok_Line2:=0;
     Mast_Results_Lex_IO.tok_begin_line:=1;
     Mast_Results_Lex_IO.tok_end_line:=1;
     Mast_Results_Lex_IO.tok_begin_col:=0;
     Mast_Results_Lex_IO.tok_end_col:=0;
     Mast_Results_Lex_IO.token_at_end_of_line:=False;
     Mast_Results_Parser_Error_Report.Total_Errors:=0;
     Mast_Results_Parser_Error_Report.Total_Warnings:=0;
     YYparse;
end MAST_Results_Parser;



