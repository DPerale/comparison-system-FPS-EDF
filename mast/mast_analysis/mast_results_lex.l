space             " "|"\t"
comment           "--"(.)*
new_line          "\n"
left_paren        "("
right_paren       ")"
arrow             "=>"
comma             ","
semicolon         ";"
colon             ":"
dash              "-"

identifier        [a-z][a-z0-9_\.]*
quoted_identifier \"{identifier}\"
quoted_text       \"[a-z0-9_. /\\~!$%&()=?*,\-+:;]*\"
number            ([+-])?[0-9]+(e[0-9]+)?
float_number      ([+-])?[0-9]+"."[0-9]+(e([+-])?[0-9]+)?
time              T[0-2][0-9]{colon}[0-5][0-9]({colon}[0-5][0-9])?
date              20[0-9][0-9]{dash}[0-1][0-9]{dash}[0-3][0-9]({time})?
path              ([a-zA-Z]:)?[/\\][a-z/\\0-9_.~]*
percentage        ({number}|{float_number})"%"
large_percentage  ">="{percentage}

yes               "yes"
no                "no"

real_time_situation             "real_time_situation"
model_name                      "model_name"
model_date                      "model_date"
generation_tool                 "generation_tool"
generation_profile              "generation_profile"
generation_date                 "generation_date"
results                         "results"
the_type                        "type"
slack                           "slack"
value                           "value"
trace                           "trace"
pathname                        "pathname"

transaction                     "transaction"
name                            "name"
timing_result                   "timing_result"
event_name                      "event_name"
worst_local_response_time       "worst_local_response_time"
best_local_response_time        "best_local_response_time"
worst_blocking_time             "worst_blocking_time"
num_of_suspensions              "num_of_suspensions"
worst_global_response_times     "worst_global_response_times"
best_global_response_times      "best_global_response_times"
jitters                         "jitters"

simulation_timing_result        "simulation_timing_result"
avg_local_response_time         "avg_local_response_time"
avg_blocking_time               "avg_blocking_time"
max_preemption_time             "max_preemption_time"
suspension_time                 "suspension_time"
num_of_queued_activations       "num_of_queued_activations"
avg_global_response_times       "avg_global_response_times"
local_miss_ratios               "local_miss_ratios"
global_miss_ratios              "global_miss_ratios"
referenced_event                "referenced_event"
time_value                      "time_value"
deadline                        "deadline"
ratio                           "ratio"
miss_ratios                     "miss_ratios"

processing_resource             "processing_resource"
detailed_utilization            "detailed_utilization"
total                           "total"
application                     "application"
context_switch                  "context_switch"
timer                           "timer"
driver                          "driver"
ready_queue_size                "ready_queue_size"
max_num                         "max_num"

operation                       "operation"

scheduling_server               "scheduling_server"
scheduling_parameters           "scheduling_parameters"
server_sched_parameters         "server_sched_parameters"
synchronization_parameters      "synchronization_parameters"
server_synch_parameters         "server_synch_parameters"

shared_resource                 "shared_resource"
priority_ceiling                "priority_ceiling"
ceiling                         "ceiling"
level                           "level"
queue_size                      "queue_size"
utilization                     "utilization"

fixed_priority_policy           "fixed_priority_policy"
non_preemptible_fp_policy       "non_preemptible_fp_policy"
interrupt_fp_policy             "interrupt_fp_policy"     
the_priority                    "the_priority"        
polling_policy                  "polling_policy"      
polling_period                  "polling_period"      
polling_worst_overhead          "polling_worst_overhead"  
polling_best_overhead           "polling_best_overhead"  
polling_avg_overhead            "polling_avg_overhead"  
sporadic_server_policy          "sporadic_server_policy"  
normal_priority                 "normal_priority"        
background_priority             "background_priority"  
initial_capacity                "initial_capacity"  
replenishment_period            "replenishment_period"  
max_pending_replenishments      "max_pending_replenishments"  
preassigned                     "preassigned"  

edf_policy                      "edf_policy"
srp_parameters                  "srp_parameters"
the_preemption_level            "preemption_level"


%%

{left_paren}     {return left_paren;}
{right_paren}    {return right_paren;}
{arrow}          {return arrow;}
{comma}          {return comma;}
{semicolon}      {return semicolon;}

{yes}            {YYVal.Flag:=True; return yes_no;}
{no}             {YYVal.Flag:=False; return yes_no;}


{real_time_situation}            {return real_time_situation;}
{model_name}                     {return model_name;}
{model_date}                     {return model_date;}
{model_name}                     {return model_name;}
{model_date}                     {return model_date;}
{generation_tool}                {return generation_tool;}
{generation_profile}             {return generation_profile;}
{generation_date}                {return generation_date;}
{results}                        {return results;}
{the_type}                       {return the_type;}
{slack}                          {return slack;}
{value}                          {return value;}
{trace}                          {return trace;}
{pathname}                       {return pathname;}

{transaction}                    {return transaction;}
{name}                           {return name;}
{timing_result}                  {return timing_result;}
{event_name}                     {return event_name;}
{worst_local_response_time}      {return worst_local_response_time;}
{best_local_response_time}       {return best_local_response_time;}
{worst_blocking_time}            {return worst_blocking_time;}
{num_of_suspensions}             {return num_of_suspensions;}
{worst_global_response_times}    {return worst_global_response_times;}
{best_global_response_times}     {return best_global_response_times;}
{jitters}                        {return jitters;}

{simulation_timing_result}       {return simulation_timing_result;}
{avg_local_response_time}        {return avg_local_response_time;}
{avg_blocking_time}              {return avg_blocking_time;}
{max_preemption_time}            {return max_preemption_time;}
{suspension_time}                {return suspension_time;}
{num_of_queued_activations}      {return num_of_queued_activations;}
{avg_global_response_times}      {return avg_global_response_times;}
{local_miss_ratios}              {return local_miss_ratios;}
{global_miss_ratios}             {return global_miss_ratios;}
{referenced_event}               {return referenced_event;}
{time_value}                     {return time_value;}
{deadline}                       {return deadline;}
{ratio}                          {return ratio;}
{miss_ratios}                    {return miss_ratios;}

{processing_resource}            {return processing_resource;}
{detailed_utilization}           {return detailed_utilization;}
{total}                          {return total;}
{application}                    {return application;}
{context_switch}                 {return context_switch;}
{timer}                          {return timer;}
{driver}                         {return driver;}
{ready_queue_size}               {return ready_queue_size;}
{max_num}                        {return max_num;}

{operation}                      {return operation;}

{scheduling_server}              {return scheduling_server;}
{scheduling_parameters}          {return scheduling_parameters;}
{server_sched_parameters}        {return server_sched_parameters;}
{synchronization_parameters}     {return synchronization_parameters;}
{server_synch_parameters}        {return server_synch_parameters;}

{shared_resource}                {return shared_resource;}
{priority_ceiling}               {return priority_ceiling;}
{ceiling}                        {return ceiling;}
{level}                          {return level;}
{queue_size}                     {return queue_size;}
{utilization}                    {return utilization;}

{fixed_priority_policy}           {return fixed_priority_policy;}
{non_preemptible_fp_policy}       {return non_preemptible_fp_policy;}
{interrupt_fp_policy}             {return interrupt_fp_policy;}
{the_priority}                    {return the_priority;}
{polling_policy}                  {return polling_policy;}
{polling_period}                  {return polling_period;}
{polling_worst_overhead}          {return polling_worst_overhead;}
{polling_best_overhead}           {return polling_best_overhead;}
{polling_avg_overhead}            {return polling_avg_overhead;}
{sporadic_server_policy}          {return sporadic_server_policy;}
{normal_priority}                 {return normal_priority;}
{background_priority}             {return background_priority;}
{initial_capacity}                {return initial_capacity;}
{replenishment_period}            {return replenishment_period;}
{max_pending_replenishments}      {return max_pending_replenishments;}
{preassigned}                     {return preassigned;}

{edf_policy}                      {return edf_policy;}
{srp_parameters}                  {return srp_parameters;}
{the_preemption_level}            {return the_preemption_level;}


{identifier}         {YYVal.name_index:=
                         Symbol_table.Add_or_find(to_var_string(yytext));
                         return identifier;}
{date}               {YYVal.date:="                   ";
                         YYVal.date(1..YYtext'length):=YYtext;
                         return date;}
{quoted_identifier}  {YYVal.name_index:=
                         Symbol_table.Add_or_find
                             (to_var_string(yytext(2..yytext'length-1)));
                         return identifier;}
{number}             {YYVal.Num:=Integer'Value(YYtext);
                         YYVal.Float_Num:=Real_Number(YYVal.Num);
                         YYVal.Is_Float:=False;
                         return number;}
{float_number}       {YYVal.Float_Num:=Real_Number'Value(YYtext);
                         YYVal.Is_Float:=True;
                         return number;}

{percentage}         {YYVal.Float_Num:=Real_Number'Value
                         (YYtext(1..yytext'length-1));
                         YYVal.Is_Float:=True;
                         return number;}

{large_percentage}   {YYVal.Float_Num:=Large_Number;
                         YYVal.Is_Float:=True;
                         return number;}

{quoted_text}        {YYVal.text:=to_var_string(yytext(2..yytext'length-1));
                         return quoted_text;}

{path}               {YYVal.text:=to_var_string(yytext);
                         return path;}

{space}        {null;}         
{comment}      {null;}         
{new_line}     {null;}         
.              {return Error;}

%%

with MAST_Results_Parser_Tokens; use MAST_Results_Parser_Tokens;
with Var_Strings; use Var_Strings;
with Symbol_Table; use Symbol_Table;
package MAST_Results_Lex is

    function YYlex return Token;

end MAST_Results_Lex;

package body MAST_Results_Lex is

##

end MAST_Results_Lex;
