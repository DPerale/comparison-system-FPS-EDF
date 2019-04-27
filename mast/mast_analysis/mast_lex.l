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
number            ([+-])?[0-9]+(e[0-9]+)?
float_number      ([+-])?[0-9]+"."[0-9]+(e([+-])?[0-9]+)?
time              T[0-2][0-9]{colon}[0-5][0-9]({colon}[0-5][0-9])?
date              20[0-9][0-9]{dash}[0-1][0-9]{dash}[0-3][0-9]({time})?

yes               "yes"
no                "no"

model_name                      "model_name"
model_date                      "model_date"
model                           "model"
processing_resource             "processing_resource"
the_type                        "type"
fixed_priority_processor        "fixed_priority_processor"
fixed_priority_network          "fixed_priority_network"
name                            "name"
max_priority                    "max_priority"
min_priority                    "min_priority"
max_interrupt_priority          "max_interrupt_priority"
min_interrupt_priority          "min_interrupt_priority"
worst_context_switch            "worst_context_switch"
avg_context_switch              "avg_context_switch"
best_context_switch             "best_context_switch"
best_isr_switch                 "best_isr_switch"
worst_isr_switch                "worst_isr_switch"
avg_isr_switch                  "avg_isr_switch"
best_overhead                   "best_overhead"
worst_overhead                  "worst_overhead"
avg_overhead                    "avg_overhead"
system_timer                    "system_timer"
alarm_clock                     "alarm_clock"
ticker                          "ticker"
speed_factor                    "speed_factor"
packet_worst_overhead           "packet_worst_overhead"
packet_avg_overhead             "packet_avg_overhead"
packet_best_overhead            "packet_best_overhead"
transmission                    "transmission"
simplex                         "simplex"
half_duplex                     "half_duplex"
full_duplex                     "full_duplex"
list_of_drivers                 "list_of_drivers"
max_blocking                    "max_blocking"
max_packet_transmission_time    "max_packet_transmission_time"
min_packet_transmission_time    "min_packet_transmission_time"
packet_driver                   "packet_driver"
character_packet_driver         "character_packet_driver"
packet_server                   "packet_server"
packet_receive_operation        "packet_receive_operation"
packet_send_operation           "packet_send_operation"
character_server                "character_server"
character_receive_operation     "character_receive_operation"
character_send_operation        "character_send_operation"
character_transmission_time     "character_transmission_time"

shared_resource                 "shared_resource"
immediate_ceiling_resource      "immediate_ceiling_resource"
ceiling                         "ceiling"
priority_inheritance_resource   "priority_inheritance_resource"

operation                       "operation"
simple                          "simple"
composite                       "composite"
enclosing                       "enclosing"
worst_case_execution_time       "worst_case_execution_time"
avg_case_execution_time         "avg_case_execution_time"
best_case_execution_time        "best_case_execution_time"
shared_resources_list           "shared_resources_list"
shared_resources_to_lock        "shared_resources_to_lock"
shared_resources_to_unlock      "shared_resources_to_unlock"
composite_operation_list        "composite_operation_list"

event                           "event"
periodic                        "periodic"
singular                        "singular"
aperiodic                       "aperiodic"
sporadic                        "sporadic"
unbounded_ev                    "unbounded"
bursty                          "bursty"
period                          "period"
max_jitter                      "max_jitter"
phase                           "phase"
avg_interarrival                "avg_interarrival"
distribution                    "distribution"
uniform                         "uniform"
poisson                         "poisson"
min_interarrival                "min_interarrival"
bound_interval                  "bound_interval"
max_arrivals                    "max_arrivals"

transaction                     "transaction"
event_handlers                  "event_handlers"
internal_events                 "internal_events"

scheduling_server               "scheduling_server"
fixed_priority                  "fixed_priority"
new_sched_parameters            "new_sched_parameters"
server_sched_parameters         "server_sched_parameters"
server_processing_resource      "server_processing_resource"

hard_global_deadline            "hard_global_deadline"
soft_global_deadline            "soft_global_deadline"
deadline                        "deadline"
hard_local_deadline             "hard_local_deadline"
soft_local_deadline             "soft_local_deadline"
global_max_miss_ratio           "global_max_miss_ratio"
local_max_miss_ratio            "local_max_miss_ratio"
max_output_jitter_req           "max_output_jitter_req"
max_output_jitter               "max_output_jitter"
requirements_list               "requirements_list"
ratio                           "ratio"

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
overridden_fixed_priority       "overridden_fixed_priority"
overridden_permanent_fp         "overridden_permanent_fp"

activity                        "activity"
system_timed_activity           "system_timed_activity"
activity_operation              "activity_operation"
input_event                     "input_event"
output_event                    "output_event"
timing_requirements             "timing_requirements"
activity_server                 "activity_server"
concentrator                    "concentrator"
input_events_list               "input_events_list"
barrier                         "barrier"
delivery_server                 "delivery_server"
delivery_policy                 "delivery_policy"
request_policy                  "request_policy"
query_server                    "query_server"
output_events_list              "output_events_list"
multicast                       "multicast"
rate_divisor                    "rate_divisor"
rate_factor                     "rate_factor"
the_delay                       "delay"
delay_max_interval              "delay_max_interval"
delay_min_intervla              "delay_min_interval"
offset                          "offset"
external_events                 "external_events"
referenced_event                "referenced_event"

regular                         "regular"
link                            "link"

scan                            "scan"
prioritized                     "prioritized"
random                          "random"
fifo                            "fifo"
lifo                            "lifo"

regular_processor               "regular_processor"
packet_based_network            "packet_based_network"
scheduler                       "scheduler"
primary_scheduler               "primary_scheduler"
secondary_scheduler             "secondary_scheduler"
policy                          "policy" 
host                            "host"
server                          "server" 

edf                             "edf" 
fp_packet_based                 "fp_packet_based" 

edf_policy                      "edf_policy" 

srp_parameters                  "srp_parameters" 
the_preemption_level            "preemption_level" 

the_synchronization_parameters  "synchronization_parameters"

srp_resource                    "srp_resource" 

throughput                      "throughput"
max_packet_size                 "max_packet_size"
min_packet_size                 "min_packet_size"
message_transmission            "message_transmission"
max_message_size                "max_message_size"
avg_message_size                "avg_message_size"
min_message_size                "min_message_size"
packet_overhead_max_size        "packet_overhead_max_size"
packet_overhead_avg_size        "packet_overhead_avg_size"
packet_overhead_min_size        "packet_overhead_min_size"
system_pip_behaviour            "system_pip_behaviour"
system_pip_behavior             "system_pip_behavior"
strict                          "strict"
posix                           "posix"

rtep_packet_driver               "rtep_packet_driver"
number_of_stations               "number_of_stations"
token_delay                      "token_delay"
failure_timeout                  "failure_timeout"
token_transmission_retries       "token_transmission_retries"
packet_transmission_retries      "packet_transmission_retries"
packet_interrupt_server          "packet_interrupt_server"
packet_isr_operation             "packet_isr_operation"
token_check_operation            "token_check_operation"
token_manage_operation           "token_manage_operation"
packet_discard_operation         "packet_discard_operation"
token_retransmission_operation   "token_retransmission_operation"
packet_retransmission_operation  "packet_retransmission_operation"

message_partitioning             "message_partitioning"
rta_overhead_model               "rta_overhead_model"
coupled                          "coupled"
decoupled                        "decoupled"

%%

{left_paren}     {return left_paren;}
{right_paren}    {return right_paren;}
{arrow}          {return arrow;}
{comma}          {return comma;}
{semicolon}      {return semicolon;}

{yes}            {YYVal.Flag:=True; return yes_no;}
{no}             {YYVal.Flag:=False; return yes_no;}


{model_name}                      {return model_name;}
{model_date}                      {return model_date;}
{model}                           {return model;}
{processing_resource}             {return processing_resource;}
{the_type}                        {return the_type;}
{fixed_priority_processor}        {return fixed_priority_processor;}
{fixed_priority_network}          {return fixed_priority_network;}
{name}                            {return name;}
{max_priority}                    {return max_priority;}
{min_priority}                    {return min_priority;}
{max_interrupt_priority}          {return max_interrupt_priority;}
{min_interrupt_priority}          {return min_interrupt_priority;}
{worst_context_switch}            {return worst_context_switch;}
{avg_context_switch}              {return avg_context_switch;}
{best_context_switch}             {return best_context_switch;}
{worst_isr_switch}                {return worst_isr_switch;}
{avg_isr_switch}                  {return avg_isr_switch;}
{best_isr_switch}                 {return best_isr_switch;}
{worst_overhead}                  {return worst_overhead;}
{avg_overhead}                    {return avg_overhead;}
{best_overhead}                   {return best_overhead;}
{system_timer}                    {return system_timer;}
{alarm_clock}                     {return alarm_clock;}
{ticker}                          {return ticker;}
{speed_factor}                    {return speed_factor;}
{packet_worst_overhead}           {return packet_worst_overhead;}
{packet_avg_overhead}             {return packet_avg_overhead;}
{packet_best_overhead}            {return packet_best_overhead;}
{transmission}                    {return transmission;}
{simplex}                         {YYVal.Num:=0;
                                   return trans_kind;}
{half_duplex}                     {YYVal.Num:=1;
                                   return trans_kind;}
{full_duplex}                     {YYVal.Num:=2;
                                   return trans_kind;}
{list_of_drivers}                 {return list_of_drivers;}
{max_blocking}                    {return max_blocking;}
{max_packet_transmission_time}    {return max_packet_transmission_time;}
{min_packet_transmission_time}    {return min_packet_transmission_time;}
{packet_driver}                   {return packet_driver;}
{character_packet_driver}         {return character_packet_driver;}
{packet_server}                   {return packet_server;}
{packet_receive_operation}        {return packet_receive_operation;}
{packet_send_operation}           {return packet_send_operation;}
{character_server}                {return character_server;}
{character_receive_operation}     {return character_receive_operation;}
{character_send_operation}        {return character_send_operation;}
{character_transmission_time}     {return character_transmission_time;}

{shared_resource}                 {return shared_resource;}
{immediate_ceiling_resource}      {return immediate_ceiling_resource;}
{ceiling}                         {return ceiling;}
{priority_inheritance_resource}   {return priority_inheritance_resource;}

{operation}                       {return operation;}
{simple}                          {return simple;}
{composite}                       {return composite;}
{enclosing}                       {return enclosing;}
{worst_case_execution_time}       {return worst_case_execution_time;}
{avg_case_execution_time}         {return avg_case_execution_time;}
{best_case_execution_time}        {return best_case_execution_time;}
{shared_resources_list}           {return shared_resources_list;}
{shared_resources_to_lock}        {return shared_resources_to_lock;}
{shared_resources_to_unlock}      {return shared_resources_to_unlock;}
{composite_operation_list}        {return composite_operation_list;}

{event}                           {return event;}
{periodic}                        {return periodic;}
{singular}                        {return singular;}
{aperiodic}                       {return aperiodic;}
{sporadic}                        {return sporadic;}
{unbounded_ev}                    {return unbounded_ev;}
{bursty}                          {return bursty;}
{period}                          {return period;}
{max_jitter}                      {return max_jitter;}
{phase}                           {return phase;}
{avg_interarrival}                {return avg_interarrival;}
{distribution}                    {return distribution;}
{uniform}                         {YYVal.Num:=0;
                                   return dist_function;}
{poisson}                         {YYVal.Num:=1;
                                   return dist_function;}
{min_interarrival}                {return min_interarrival;}
{bound_interval}                  {return bound_interval;}
{max_arrivals}                    {return max_arrivals;}

{transaction}                     {return transaction;}
{event_handlers}                  {return event_handlers;}
{internal_events}                 {return internal_events;}

{scheduling_server}               {return scheduling_server;}
{fixed_priority}                  {return fixed_priority;}
{new_sched_parameters}            {return new_sched_parameters;}
{server_sched_parameters}         {return server_sched_parameters;}
{server_processing_resource}      {return server_processing_resource;}

{hard_global_deadline}            {return hard_global_deadline;}
{soft_global_deadline}            {return soft_global_deadline;}
{deadline}                        {return deadline;}
{hard_local_deadline}             {return hard_local_deadline;}
{soft_local_deadline}             {return soft_local_deadline;}
{global_max_miss_ratio}           {return global_max_miss_ratio;}
{local_max_miss_ratio}            {return local_max_miss_ratio;}
{max_output_jitter_req}           {return max_output_jitter_req;}
{max_output_jitter}               {return max_output_jitter;}
{composite}                       {return composite;}
{requirements_list}               {return requirements_list;}
{ratio}                           {return ratio;}

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
{overridden_fixed_priority}       {return overridden_fixed_priority;}
{overridden_permanent_fp}         {return overridden_permanent_fp;}

{activity}                        {return activity;}
{system_timed_activity}           {return system_timed_activity;}
{activity_operation}              {return activity_operation;}
{input_event}                     {return input_event;}
{output_event}                    {return output_event;}
{timing_requirements}             {return timing_requirements;}
{activity_server}                 {return activity_server;}
{concentrator}                    {return concentrator;}
{input_events_list}               {return input_events_list;}
{barrier}                         {return barrier;}
{delivery_server}                 {return delivery_server;}
{delivery_policy}                 {return delivery_policy;}
{request_policy}                  {return request_policy;}
{query_server}                    {return query_server;}
{output_events_list}              {return output_events_list;}
{multicast}                       {return multicast;}
{rate_divisor}                    {return rate_divisor;}
{rate_factor}                     {return rate_factor;}
{the_delay}                       {return the_delay;}
{delay_max_interval}              {return delay_max_interval;}
{delay_min_intervla}              {return delay_min_interval;}
{offset}                          {return offset;}
{external_events}                 {return external_events;}
{referenced_event}                {return referenced_event;}

{regular}                         {return regular;}
{link}                            {return link;}

{scan}                            {YYVal.Num:=0;
                                   return policy;}
{prioritized}                     {YYVal.Num:=1;
                                   return policy;}
{random}                          {YYVal.Num:=1;
                                   return policy;}
{fifo}                            {YYVal.Num:=2;
                                   return policy;}
{lifo}                            {YYVal.Num:=3;
                                   return policy;}

{regular_processor}               {return regular_processor;}
{packet_based_network}            {return packet_based_network;}
{scheduler}                       {return scheduler;}
{primary_scheduler}               {return primary_scheduler;}
{secondary_scheduler}             {return secondary_scheduler;}
{policy}                          {YYVal.Num:=-1;
                                   return policy;} 
{host}                            {return host;}
{server}                          {return server;} 

{edf}                             {return edf;} 
{fp_packet_based}                 {return fp_packet_based;} 

{edf_policy}                      {return edf_policy;} 

{srp_parameters}                  {return srp_parameters;} 
{the_preemption_level}            {return the_preemption_level;} 

{the_synchronization_parameters}  {return the_synchronization_parameters;}

{srp_resource}                    {return srp_resource;} 

{throughput}                      {return throughput;}
{max_packet_size}                 {return max_packet_size;}
{min_packet_size}                 {return min_packet_size;}
{message_transmission}            {return message_transmission;}
{max_message_size}                {return max_message_size;}
{avg_message_size}                {return avg_message_size;}
{min_message_size}                {return min_message_size;}
{packet_overhead_max_size}        {return packet_overhead_max_size;}
{packet_overhead_avg_size}        {return packet_overhead_avg_size;}
{packet_overhead_min_size}        {return packet_overhead_min_size;}

{system_pip_behaviour}            {return system_pip_behaviour;}
{system_pip_behavior}             {return system_pip_behaviour;}
{strict}                          {YYVal.flag:=True; return pip_behaviour;}
{posix}                           {YYVal.flag:=False; return pip_behaviour;}

{rtep_packet_driver}              {return rtep_packet_driver;}
{number_of_stations}              {return number_of_stations;}
{token_delay}                     {return token_delay;}
{failure_timeout}                 {return failure_timeout;}
{token_transmission_retries}      {return token_transmission_retries;}
{packet_transmission_retries}     {return packet_transmission_retries;}
{packet_interrupt_server}         {return packet_interrupt_server;}
{packet_isr_operation}            {return packet_isr_operation;}
{token_check_operation}           {return token_check_operation;}
{token_manage_operation}          {return token_manage_operation;}
{packet_discard_operation}        {return packet_discard_operation;}
{token_retransmission_operation}  {return token_retransmission_operation;}
{packet_retransmission_operation} {return packet_retransmission_operation;}

{message_partitioning}            {return message_partitioning;}
{rta_overhead_model}              {return rta_overhead_model;}
{coupled}                         {YYVal.Num:=0; 
                                   return rta_overhead_model_value;}
{decoupled}                       {YYVal.Num:=1; 
                                   return rta_overhead_model_value;}

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
{number}             {begin
                         YYVal.Num:=Integer'Value(YYtext);
                         YYVal.Float_Num:=Real_Number(YYVal.Num);
                         YYVal.Is_Float:=False;
                         return number;
                      exception
                         when Constraint_Error =>
                             return Error;
                      end;
                      }
{float_number}       {YYVal.Float_Num:=Real_Number'Value(YYtext);
                         YYVal.Is_Float:=True;
                         return number;}

{space}        {null;}         
{comment}      {null;}         
{new_line}     {null;}         
.              {return Error;}

%%

with MAST_Parser_Tokens; use MAST_Parser_Tokens;
with Var_Strings; use Var_Strings;
with Symbol_Table; use Symbol_Table;
package MAST_Lex is

    function YYlex return Token;

end MAST_Lex;

package body MAST_Lex is

##

end MAST_Lex;
