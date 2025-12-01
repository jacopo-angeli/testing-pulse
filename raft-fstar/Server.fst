module Server
#lang-pulse

open Pulse.Lib.Pervasives
open Pulse.Lib.Array
open FStar.Mul

module SZ = FStar.SizeT
module U8 = FStar.UInt8
module U32 = FStar.UInt32

fn extract_term
  (arr:Pulse.Lib.Array.array U8.t)
  (#p:Pulse.Lib.Pervasives.perm)
  (#s:Pulse.Lib.Pervasives.erased (Seq.seq U8.t))
  requires Pulse.Lib.Array.pts_to arr #p s ** pure (Seq.length s > 7)
  returns U32.t
  ensures Pulse.Lib.Array.pts_to arr #p s
{
  let b0 = arr.(4sz); 
  let b1 = arr.(5sz);
  let b2 = arr.(6sz);
  let b3 = arr.(7sz); 
  
  let v_nat = 
    (U8.v b0 * 16777216) + 
    (U8.v b1 * 65536) +    
    (U8.v b2 * 256) +           
    U8.v b3;             

  U32.uint_to_t v_nat
}

fn extract_leader_id
  (arr:Pulse.Lib.Array.array U8.t)
  (#p:Pulse.Lib.Pervasives.perm)
  (#s:Pulse.Lib.Pervasives.erased (Seq.seq U8.t))
  requires Pulse.Lib.Array.pts_to arr #p s ** pure (Seq.length s > 4)
  returns U32.t
  ensures Pulse.Lib.Array.pts_to arr #p s
{
  let b0 = arr.(0sz); 
  let b1 = arr.(1sz);
  let b2 = arr.(2sz);
  let b3 = arr.(3sz); 
  
  let v_nat = 
    (U8.v b0 * 16777216) + 
    (U8.v b1 * 65536) +    
    (U8.v b2 * 256) +      
     U8.v b3; 

  U32.uint_to_t v_nat
}

[@@ Rust_derive "Debug, Clone, PartialEq"]
type raft_state = | Follower | Candidate | Leader

[@@ Rust_derive "Debug"]
type server_config = {
  default_leader : option U32.t;
}

type server_state = {
  current_term:U32.t;
  state:raft_state;
  voted_for: option U32.t;
  commit_index: U32.t;
  previous_log_index: U32.t;
}

type server = {
  id : U32.t;
  state : server_state;
  config : server_config;
}

fn handle_heartbeat 
  (s:ref server) 
  (data: array U8.t)
  (#p_s: Pulse.Lib.Pervasives.perm)
  (#p_data: Pulse.Lib.Pervasives.perm)
  (#st: Pulse.Lib.Pervasives.erased server)
  (#s_seq: Pulse.Lib.Pervasives.erased (Seq.seq U8.t))
requires 
  Pulse.Lib.Pervasives.pts_to s st **
  Pulse.Lib.Array.pts_to data #p_data s_seq **
  pure (Seq.length s_seq > 7)
returns unit
ensures  
  (exists* st'. Pulse.Lib.Pervasives.pts_to s st') **
  Pulse.Lib.Array.pts_to data #p_data s_seq
{
  let server = !s;
  if (server.state.state = Leader)
  {
    let term = extract_term data;
    
    if (U32.gt server.state.current_term term){
      s :=  { server with 
               state = { server.state with 
                 state = Follower} }
    };

    if (U32.eq server.state.current_term term) {
      let leader_id = extract_leader_id data;

      match server.config.default_leader {
        None -> {
          if (U32.lt server.id leader_id){
            s :=  { 
                    server with 
                      state = { server.state with 
                        state = Follower; 
                        current_term = term};
                  }
          }
        }
        Some x -> {
          if (U32.ne server.id x){
            s :=  { 
                    server with 
                      state = { server.state with 
                        state = Follower; 
                        current_term = term };
                  }
          } else {
            s := { server with 
                    state = { server.state with 
                      state = Leader} }
          }
        }
      }
    }
  }
}
