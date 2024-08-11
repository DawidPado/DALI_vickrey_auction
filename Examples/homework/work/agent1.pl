
:-use_module(library(random)).

:-dynamic object_to_sell/3.

:-dynamic portafoglio/1.

:-dynamic gain_goal/1.

:-dynamic responds/1.

:-dynamic proposal/2.

:-assert(portafoglio(0)),assert(gain_goal(0)),assert(responds(0)),write('Agent1: Portafoglio value: 0'),nl.

eve(gain(var_X)):-gain_goal(var_Y),retract(gain_goal(var_Y)),assert(gain_goal(var_X)),wake_up([agent2,agent3]),a(work).

wake_up([]).

wake_up([var_Agent|var_Agents]):-a(message(var_Agent,execute_proc(wake_up,var_Me))),wake_up(var_Agents).

evi(work):-evp(gain),a(start).

evi(work):-gain_goal(var_Y),portafoglio(var_X),var_X<var_Y,not(object_to_sell(var_N,var_R,var_P)),!,a(find),a(work),nl.

evi(work):-gain_goal(var_Y),portafoglio(var_X),var_X<var_Y,object_to_sell(var_N,var_R,var_P),!,a(start_auction),nl.

evi(work):-write('Gain reached!'),nl.

evi(find):-evp(start).

evi(find):-write('Searching for items'),nl,random(1,100,var_Prob),(var_Prob<50->random(1,100,var_ValueProb),(var_ValueProb<70->random(1,3,var_Rarity),random(100,1000,var_Price),assert(object_to_sell(item,var_Rarity,var_Price)),format('Found a valuable item Rarity: ~w, Price: ~w~n',[var_Rarity,var_Price]);write('Found trash'),nl);write('Found nothing'),nl),object_to_sell(var_N,var_R,var_Price).

evi(start_auction):-object_to_sell(var_Name,var_Rarity,var_Price),write('Starting auction for item '),nl,send_auction_invitations([agent2,agent3],var_Name,var_Rarity,var_Price),write('invitations send'),nl.

send_auction_invitations([],var__,var__,var__).

send_auction_invitations([var_Agent|var_Agents],var_Name,var_Rarity,var_Price):-a(message(var_Agent,send_message(new_item(var_Name,var_Rarity,var_Price),var_Me))),send_auction_invitations(var_Agents,var_Name,var_Rarity,var_Price).

eve(im_in(var_Agent,var_Proposal)):-format('respond recived from ~w, ~w euro ~n',[var_Agent,var_Proposal]),responds(var_R),var_NewR is var_R+1,retract(responds(var_R)),assert(responds(var_NewR)),assert(proposal(var_Agent,var_Proposal)),var_NewR=2,findall(var_Bid,proposal(var__,var_Bid),var_Bids),format('Bids: ~w, count: ~w~n',[var_Bids,var_NewR]),a(sell).

exclude_max(var_M,[],[]):-!.

exclude_max(var_M,[var_M|var_T],var_R):-exclude_max(var_M,var_T,var_R).

exclude_max(var_M,[var_H|var_T],[var_H|var_R]):-var_H\=var_M,exclude_max(var_M,var_T,var_R).

max_list([],var_Max,var_Max).

max_list([var_H|var_T],var_Max):-max_list(var_T,var_H,var_Max).

max_list([var_H|var_T],var_Acc,var_Max):-var_H>var_Acc,max_list(var_T,var_H,var_Max).

max_list([var_H|var_T],var_Acc,var_Max):-var_H=<var_Acc,max_list(var_T,var_Acc,var_Max).

evi(sell):-evp(start),responds(var_R),format('~w num of partecipant',[var_R]),nl.

evi(sell):-responds(var_Re),format('~w num of partecipant',[var_Re]),nl,findall(var_Bid,proposal(var__,var_Bid),var_Bids),max_list(var_Bids,var_HighestBid),exclude_max(var_HighestBid,var_Bids,var_RemainingBids),max_list(var_RemainingBids,var_SecondPrice),proposal(var_Winner,var_SecondPrice),object_to_sell(var_N,var_R,var_P),a(message(var_Winner,send_message(win(var_N,var_R,var_SecondPrice),var_Me))),format('~w sold to ~w for ~w!',[var_N,var_Winner,var_SecondPrice]),nl,retract(object_to_sell(var_N,var__,var__)),portafoglio(var_CurrentValue),var_NewValue is var_CurrentValue+var_SecondPrice,retract(portafoglio(var_CurrentValue)),assert(portafoglio(var_NewValue)),portafoglio(var_V),format('portafoglio value: ~w~n~n',[var_V]),retract(responds(var_Re)),assert(responds(0)),retractall(proposal(var__,var__)),a(work).

:-dynamic receive/1.

:-dynamic send/2.

:-dynamic isa/3.

receive(send_message(var_X,var_Ag)):-told(var_Ag,send_message(var_X)),call_send_message(var_X,var_Ag).

receive(propose(var_A,var_C,var_Ag)):-told(var_Ag,propose(var_A,var_C)),call_propose(var_A,var_C,var_Ag).

receive(cfp(var_A,var_C,var_Ag)):-told(var_Ag,cfp(var_A,var_C)),call_cfp(var_A,var_C,var_Ag).

receive(accept_proposal(var_A,var_Mp,var_Ag)):-told(var_Ag,accept_proposal(var_A,var_Mp),var_T),call_accept_proposal(var_A,var_Mp,var_Ag,var_T).

receive(reject_proposal(var_A,var_Mp,var_Ag)):-told(var_Ag,reject_proposal(var_A,var_Mp),var_T),call_reject_proposal(var_A,var_Mp,var_Ag,var_T).

receive(failure(var_A,var_M,var_Ag)):-told(var_Ag,failure(var_A,var_M),var_T),call_failure(var_A,var_M,var_Ag,var_T).

receive(cancel(var_A,var_Ag)):-told(var_Ag,cancel(var_A)),call_cancel(var_A,var_Ag).

receive(execute_proc(var_X,var_Ag)):-told(var_Ag,execute_proc(var_X)),call_execute_proc(var_X,var_Ag).

receive(query_ref(var_X,var_N,var_Ag)):-told(var_Ag,query_ref(var_X,var_N)),call_query_ref(var_X,var_N,var_Ag).

receive(inform(var_X,var_M,var_Ag)):-told(var_Ag,inform(var_X,var_M),var_T),call_inform(var_X,var_Ag,var_M,var_T).

receive(inform(var_X,var_Ag)):-told(var_Ag,inform(var_X),var_T),call_inform(var_X,var_Ag,var_T).

receive(refuse(var_X,var_Ag)):-told(var_Ag,refuse(var_X),var_T),call_refuse(var_X,var_Ag,var_T).

receive(agree(var_X,var_Ag)):-told(var_Ag,agree(var_X)),call_agree(var_X,var_Ag).

receive(confirm(var_X,var_Ag)):-told(var_Ag,confirm(var_X),var_T),call_confirm(var_X,var_Ag,var_T).

receive(disconfirm(var_X,var_Ag)):-told(var_Ag,disconfirm(var_X)),call_disconfirm(var_X,var_Ag).

receive(reply(var_X,var_Ag)):-told(var_Ag,reply(var_X)).

send(var_To,query_ref(var_X,var_N,var_Ag)):-tell(var_To,var_Ag,query_ref(var_X,var_N)),send_m(var_To,query_ref(var_X,var_N,var_Ag)).

send(var_To,send_message(var_X,var_Ag)):-tell(var_To,var_Ag,send_message(var_X)),send_m(var_To,send_message(var_X,var_Ag)).

send(var_To,reject_proposal(var_X,var_L,var_Ag)):-tell(var_To,var_Ag,reject_proposal(var_X,var_L)),send_m(var_To,reject_proposal(var_X,var_L,var_Ag)).

send(var_To,accept_proposal(var_X,var_L,var_Ag)):-tell(var_To,var_Ag,accept_proposal(var_X,var_L)),send_m(var_To,accept_proposal(var_X,var_L,var_Ag)).

send(var_To,confirm(var_X,var_Ag)):-tell(var_To,var_Ag,confirm(var_X)),send_m(var_To,confirm(var_X,var_Ag)).

send(var_To,propose(var_X,var_C,var_Ag)):-tell(var_To,var_Ag,propose(var_X,var_C)),send_m(var_To,propose(var_X,var_C,var_Ag)).

send(var_To,disconfirm(var_X,var_Ag)):-tell(var_To,var_Ag,disconfirm(var_X)),send_m(var_To,disconfirm(var_X,var_Ag)).

send(var_To,inform(var_X,var_M,var_Ag)):-tell(var_To,var_Ag,inform(var_X,var_M)),send_m(var_To,inform(var_X,var_M,var_Ag)).

send(var_To,inform(var_X,var_Ag)):-tell(var_To,var_Ag,inform(var_X)),send_m(var_To,inform(var_X,var_Ag)).

send(var_To,refuse(var_X,var_Ag)):-tell(var_To,var_Ag,refuse(var_X)),send_m(var_To,refuse(var_X,var_Ag)).

send(var_To,failure(var_X,var_M,var_Ag)):-tell(var_To,var_Ag,failure(var_X,var_M)),send_m(var_To,failure(var_X,var_M,var_Ag)).

send(var_To,execute_proc(var_X,var_Ag)):-tell(var_To,var_Ag,execute_proc(var_X)),send_m(var_To,execute_proc(var_X,var_Ag)).

send(var_To,agree(var_X,var_Ag)):-tell(var_To,var_Ag,agree(var_X)),send_m(var_To,agree(var_X,var_Ag)).

call_send_message(var_X,var_Ag):-send_message(var_X,var_Ag).

call_execute_proc(var_X,var_Ag):-execute_proc(var_X,var_Ag).

call_query_ref(var_X,var_N,var_Ag):-clause(agent(var_A),var__),not(var(var_X)),meta_ref(var_X,var_N,var_L,var_Ag),a(message(var_Ag,inform(query_ref(var_X,var_N),values(var_L),var_A))).

call_query_ref(var_X,var__,var_Ag):-clause(agent(var_A),var__),var(var_X),a(message(var_Ag,refuse(query_ref(variable),motivation(refused_variables),var_A))).

call_query_ref(var_X,var_N,var_Ag):-clause(agent(var_A),var__),not(var(var_X)),not(meta_ref(var_X,var_N,var__,var__)),a(message(var_Ag,inform(query_ref(var_X,var_N),motivation(no_values),var_A))).

call_agree(var_X,var_Ag):-clause(agent(var_A),var__),ground(var_X),meta_agree(var_X,var_Ag),a(message(var_Ag,inform(agree(var_X),values(yes),var_A))).

call_confirm(var_X,var_Ag,var_T):-ground(var_X),statistics(walltime,[var_Tp,var__]),asse_cosa(past_event(var_X,var_T)),retractall(past(var_X,var_Tp,var_Ag)),assert(past(var_X,var_Tp,var_Ag)).

call_disconfirm(var_X,var_Ag):-ground(var_X),retractall(past(var_X,var__,var_Ag)),retractall(past_event(var_X,var__)).

call_agree(var_X,var_Ag):-clause(agent(var_A),var__),ground(var_X),not(meta_agree(var_X,var__)),a(message(var_Ag,inform(agree(var_X),values(no),var_A))).

call_agree(var_X,var_Ag):-clause(agent(var_A),var__),not(ground(var_X)),a(message(var_Ag,refuse(agree(variable),motivation(refused_variables),var_A))).

call_inform(var_X,var_Ag,var_M,var_T):-asse_cosa(past_event(inform(var_X,var_M,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(inform(var_X,var_M,var_Ag),var__,var_Ag)),assert(past(inform(var_X,var_M,var_Ag),var_Tp,var_Ag)).

call_inform(var_X,var_Ag,var_T):-asse_cosa(past_event(inform(var_X,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(inform(var_X,var_Ag),var__,var_Ag)),assert(past(inform(var_X,var_Ag),var_Tp,var_Ag)).

call_refuse(var_X,var_Ag,var_T):-clause(agent(var_A),var__),asse_cosa(past_event(var_X,var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(var_X,var__,var_Ag)),assert(past(var_X,var_Tp,var_Ag)),a(message(var_Ag,reply(received(var_X),var_A))).

call_cfp(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_397369,var_Ontology,_397373),_397363),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_cfp(var_A,var_C,var_Ag,_397407)),a(message(var_Ag,propose(var_A,[_397407],var_AgI))),retractall(ext_agent(var_Ag,_397445,var_Ontology,_397449)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_397243,var_Ontology,_397247),_397237),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,accept_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_397313,var_Ontology,_397317)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_397131,var_Ontology,_397135),_397125),not(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,reject_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_397187,var_Ontology,_397191)).

call_accept_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(accepted_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(accepted_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(accepted_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_reject_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(rejected_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(rejected_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(rejected_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_failure(var_A,var_M,var_Ag,var_T):-asse_cosa(past_event(failed_action(var_A,var_M,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(failed_action(var_A,var_M,var_Ag),var__,var_Ag)),assert(past(failed_action(var_A,var_M,var_Ag),var_Tp,var_Ag)).

call_cancel(var_A,var_Ag):-if(clause(high_action(var_A,var_Te,var_Ag),_396695),retractall(high_action(var_A,var_Te,var_Ag)),true),if(clause(normal_action(var_A,var_Te,var_Ag),_396729),retractall(normal_action(var_A,var_Te,var_Ag)),true).

external_refused_action_propose(var_A,var_Ag):-clause(not_executable_action_propose(var_A,var_Ag),var__).

evi(external_refused_action_propose(var_A,var_Ag)):-clause(agent(var_Ai),var__),a(message(var_Ag,failure(var_A,motivation(false_conditions),var_Ai))),retractall(not_executable_action_propose(var_A,var_Ag)).

refused_message(var_AgM,var_Con):-clause(eliminated_message(var_AgM,var__,var__,var_Con,var__),var__).

refused_message(var_To,var_M):-clause(eliminated_message(var_M,var_To,motivation(conditions_not_verified)),_396511).

evi(refused_message(var_AgM,var_Con)):-clause(agent(var_Ai),var__),a(message(var_AgM,inform(var_Con,motivation(refused_message),var_Ai))),retractall(eliminated_message(var_AgM,var__,var__,var_Con,var__)),retractall(eliminated_message(var_Con,var_AgM,motivation(conditions_not_verified))).

send_jasper_return_message(var_X,var_S,var_T,var_S0):-clause(agent(var_Ag),_396359),a(message(var_S,send_message(sent_rmi(var_X,var_T,var_S0),var_Ag))).

gest_learn(var_H):-clause(past(learn(var_H),var_T,var_U),_396307),learn_if(var_H,var_T,var_U).

evi(gest_learn(var_H)):-retractall(past(learn(var_H),_396183,_396185)),clause(agente(_396205,_396207,_396209,var_S),_396201),name(var_S,var_N),append(var_L,[46,112,108],var_N),name(var_F,var_L),manage_lg(var_H,var_F),a(learned(var_H)).

cllearn:-clause(agente(_395977,_395979,_395981,var_S),_395973),name(var_S,var_N),append(var_L,[46,112,108],var_N),append(var_L,[46,116,120,116],var_To),name(var_FI,var_To),open(var_FI,read,_396077,[]),repeat,read(_396077,var_T),arg(1,var_T,var_H),write(var_H),nl,var_T==end_of_file,!,close(_396077).

send_msg_learn(var_T,var_A,var_Ag):-a(message(var_Ag,confirm(learn(var_T),var_A))).

told(var_From,send_message(var_M)):-true.

told(var_Ag,execute_proc(var__)):-true.

told(var_Ag,query_ref(var__,var__)):-true.

told(var_Ag,agree(var__)):-true.

told(var_Ag,confirm(var__),200):-true.

told(var_Ag,disconfirm(var__)):-true.

told(var_Ag,request(var__,var__)):-true.

told(var_Ag,propose(var__,var__)):-true.

told(var_Ag,accept_proposal(var__,var__),20):-true.

told(var_Ag,reject_proposal(var__,var__),20):-true.

told(var__,failure(var__,var__),200):-true.

told(var__,cancel(var__)):-true.

told(var_Ag,inform(var__,var__),70):-true.

told(var_Ag,inform(var__),70):-true.

told(var_Ag,reply(var__)):-true.

told(var__,refuse(var__,var_Xp)):-functor(var_Xp,var_Fp,var__),var_Fp=agree.

tell(var_To,var_From,send_message(var_M)):-true.

tell(var_To,var__,confirm(var__)):-true.

tell(var_To,var__,disconfirm(var__)):-true.

tell(var_To,var__,propose(var__,var__)):-true.

tell(var_To,var__,request(var__,var__)):-true.

tell(var_To,var__,execute_proc(var__)):-true.

tell(var_To,var__,agree(var__)):-true.

tell(var_To,var__,reject_proposal(var__,var__)):-true.

tell(var_To,var__,accept_proposal(var__,var__)):-true.

tell(var_To,var__,failure(var__,var__)):-true.

tell(var_To,var__,query_ref(var__,var__)):-true.

tell(var_To,var__,eve(var__)):-true.

tell(var__,var__,refuse(var_X,var__)):-functor(var_X,var_F,var__),(var_F=send_message;var_F=query_ref).

tell(var_To,var__,inform(var__,var_M)):-true;var_M=motivation(refused_message).

tell(var_To,var__,inform(var__)):-true,var_To\=user.

tell(var_To,var__,propose_desire(var__,var__)):-true.

meta(var_P,var_V,var_AgM):-functor(var_P,var_F,var_N),var_N=0,clause(agent(var_Ag),var__),clause(ontology(var_Pre,[var_Rep,var_Host],var_Ag),var__),if((eq_property(var_F,var_V,var_Pre,[var_Rep,var_Host]);same_as(var_F,var_V,var_Pre,[var_Rep,var_Host]);eq_class(var_F,var_V,var_Pre,[var_Rep,var_Host])),true,if(clause(ontology(var_PreM,[var_RepM,var_HostM],var_AgM),var__),if((eq_property(var_F,var_V,var_PreM,[var_RepM,var_HostM]);same_as(var_F,var_V,var_PreM,[var_RepM,var_HostM]);eq_class(var_F,var_V,var_PreM,[var_RepM,var_HostM])),true,false),false)).

meta(var_P,var_V,var_AgM):-functor(var_P,var_F,var_N),(var_N=1;var_N=2),clause(agent(var_Ag),var__),clause(ontology(var_Pre,[var_Rep,var_Host],var_Ag),var__),if((eq_property(var_F,var_H,var_Pre,[var_Rep,var_Host]);same_as(var_F,var_H,var_Pre,[var_Rep,var_Host]);eq_class(var_F,var_H,var_Pre,[var_Rep,var_Host])),true,if(clause(ontology(var_PreM,[var_RepM,var_HostM],var_AgM),var__),if((eq_property(var_F,var_H,var_PreM,[var_RepM,var_HostM]);same_as(var_F,var_H,var_PreM,[var_RepM,var_HostM]);eq_class(var_F,var_H,var_PreM,[var_RepM,var_HostM])),true,false),false)),var_P=..var_L,substitute(var_F,var_L,var_H,var_Lf),var_V=..var_Lf.

meta(var_P,var_V,var__):-functor(var_P,var_F,var_N),var_N=2,symmetric(var_F),var_P=..var_L,delete(var_L,var_F,var_R),reverse(var_R,var_R1),append([var_F],var_R1,var_R2),var_V=..var_R2.

meta(var_P,var_V,var_AgM):-clause(agent(var_Ag),var__),functor(var_P,var_F,var_N),var_N=2,(symmetric(var_F,var_AgM);symmetric(var_F)),var_P=..var_L,delete(var_L,var_F,var_R),reverse(var_R,var_R1),clause(ontology(var_Pre,[var_Rep,var_Host],var_Ag),var__),if((eq_property(var_F,var_Y,var_Pre,[var_Rep,var_Host]);same_as(var_F,var_Y,var_Pre,[var_Rep,var_Host]);eq_class(var_F,var_Y,var_Pre,[var_Rep,var_Host])),true,if(clause(ontology(var_PreM,[var_RepM,var_HostM],var_AgM),var__),if((eq_property(var_F,var_Y,var_PreM,[var_RepM,var_HostM]);same_as(var_F,var_Y,var_PreM,[var_RepM,var_HostM]);eq_class(var_F,var_Y,var_PreM,[var_RepM,var_HostM])),true,false),false)),append([var_Y],var_R1,var_R2),var_V=..var_R2.

meta(var_P,var_V,var_AgM):-clause(agent(var_Ag),var__),clause(ontology(var_Pre,[var_Rep,var_Host],var_Ag),var__),functor(var_P,var_F,var_N),var_N>2,if((eq_property(var_F,var_H,var_Pre,[var_Rep,var_Host]);same_as(var_F,var_H,var_Pre,[var_Rep,var_Host]);eq_class(var_F,var_H,var_Pre,[var_Rep,var_Host])),true,if(clause(ontology(var_PreM,[var_RepM,var_HostM],var_AgM),var__),if((eq_property(var_F,var_H,var_PreM,[var_RepM,var_HostM]);same_as(var_F,var_H,var_PreM,[var_RepM,var_HostM]);eq_class(var_F,var_H,var_PreM,[var_RepM,var_HostM])),true,false),false)),var_P=..var_L,substitute(var_F,var_L,var_H,var_Lf),var_V=..var_Lf.

meta(var_P,var_V,var_AgM):-clause(agent(var_Ag),var__),clause(ontology(var_Pre,[var_Rep,var_Host],var_Ag),var__),functor(var_P,var_F,var_N),var_N=2,var_P=..var_L,if((eq_property(var_F,var_H,var_Pre,[var_Rep,var_Host]);same_as(var_F,var_H,var_Pre,[var_Rep,var_Host]);eq_class(var_F,var_H,var_Pre,[var_Rep,var_Host])),true,if(clause(ontology(var_PreM,[var_RepM,var_HostM],var_AgM),var__),if((eq_property(var_F,var_H,var_PreM,[var_RepM,var_HostM]);same_as(var_F,var_H,var_PreM,[var_RepM,var_HostM]);eq_class(var_F,var_H,var_PreM,[var_RepM,var_HostM])),true,false),false)),substitute(var_F,var_L,var_H,var_Lf),var_V=..var_Lf.
