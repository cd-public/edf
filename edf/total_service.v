Require Import rt.util.all.
Require Import rt.model.time rt.model.arrival.basic.job rt.model.arrival.basic.task rt.model.arrival.basic.arrival_sequence rt.model.priority.
Require Import rt.model.schedule.uni.schedule rt.model.schedule.uni.schedulability rt.model.schedule.uni.basic.platform.
From mathcomp Require Import ssreflect ssrbool ssrfun eqtype ssrnat seq fintype bigop.


Module TotalService.

  Import UniprocessorSchedule Schedulability Platform Job.

  (* In this section, we prove some useful lemmas about total_service. *)
  Section Lemmas.

    Context {Task: eqType}.
    Context {Job: eqType}.
    Variable job_arrival: Job -> time.
    Variable job_cost: Job -> time.
    Variable job_deadline: Job -> time.
    Variable job_task: Job -> Task.

    (* Consider any job arrival sequence with no duplicate jobs... *)
    Context {arr_seq: arrival_sequence Job}.
    Hypothesis H_arrival_sequence_is_a_set:
      arrival_sequence_is_a_set arr_seq.

    (* ... and any schedule of this arrival sequence. *)
    Variable sched: schedule Job.

    (* Assume that jobs only execute after they arrived. *)
    Check jobs_must_arrive_to_execute sched.
    Hypothesis H_jobs_must_arrive_to_execute:
      jobs_must_arrive_to_execute job_arrival sched.
    Check arrived_before.

    (* added hypothesis. need to fix.*)
    Lemma busy_last_instant:
      forall t d,  (~~ is_idle sched (t + d)) 
      ->   ( \sum_(j <- jobs_arrived_before arr_seq (t + d).+1)
      service_during sched j t (t + d).+1)
            =   ((\sum_(j <- jobs_arrived_before arr_seq (t + d))
                   service_during sched j t (t + d)) + 1).
    Proof.
      Admitted.

    (* added hypothesis. need to fix.*)
    Lemma idle_last_instant:
      forall t d,  (is_idle sched (t + d)) 
      ->   ( \sum_(j <- jobs_arrived_before arr_seq (t + d).+1)
      service_during sched j t (t + d).+1)
            =   ((\sum_(j <- jobs_arrived_before arr_seq (t + d))
                   service_during sched j t (t + d)) + 0).
    Proof.
      Admitted.

    (* The total service provided is bounded by the length of the interval. *)
    Lemma total_service_bounded_by_interval_length:
      forall (t:time) (d:time), total_service_during sched t (t + d) <= d.
    Proof.
      intros t d. elim d.
      unfold total_service_during. replace (t+0) with t; auto.
      rewrite [\sum_(t <= t0 < t)_]big_geq. auto. auto.
      move => n. intros IH.
      unfold total_service_during. nat_norm.
      rewrite [\sum_(t <= t0 < (t+n).+1)_]big_nat_recr. Focus 2. apply leq_addr.
      replace (\big[addn_monoid/0]_(t <= i < t + n)_) with (total_service_during sched t (t+n)); auto.
      case_eq(~~ is_idle sched (t+n)); intros CaseH.
      rewrite -> addn1. apply IH.
      rewrite -> addn0. rewrite -> leqW. auto. apply IH.
      Qed.

    (* The total service during an interval is the sum of service
       of all jobs that arrive before the end of the interval. *)
    Lemma sum_of_service_of_jobs_is_total_service:
      forall (t:time) (d:time), total_service_during sched t (t+d) =
                                \sum_(j <- (jobs_arrived_before arr_seq (t+d))) service_during sched j t (t + d).
    Proof.
      intros t.
      unfold total_service_during in *.
      induction d.
      replace (t+0) with t by trivial.
      rewrite [\sum_(t <= t0 < t)_]big_geq; trivial.
      unfold service_during in *.
      rewrite [\sum_(j <- jobs_arrived_before arr_seq t)
                \sum_(t <= t0 < t)_]exchange_big.
      rewrite [\big[addn_comoid/0]_(t <= j < t)_]big_geq; auto; auto.
      rewrite -> big_cat_nat with (n := t+d);
        [> | apply leq_addr | nat_norm; apply leqnSn].
      unfold jobs_must_arrive_to_execute in *.
      rewrite -> big_cat_nat with (n := t+d) in IHd;
        [> | apply leq_addr | auto].
      rewrite [\big[addn_monoid/0]_(t + d <= i < t + d)_]big_geq in IHd; auto. 
      rewrite -> addn0 in IHd.
      rewrite -> IHd. nat_norm.
      rewrite[\big[addn_monoid/0]_(t + d <= i < (t + d).+1)_]big_nat1.
      
      case_eq (~~ is_idle sched (t + d)). intro H.
      replace (addn_monoid (\sum_(j <- jobs_arrived_before arr_seq (t + d))
                             service_during sched j t (t + d)) (nat_of_bool true))
        with
          (addn_monoid (\sum_(j <- jobs_arrived_before arr_seq (t + d))
                         service_during sched j t (t + d)) 1); auto. symmetry.
      apply busy_last_instant; apply H.
      intro H.
      replace (addn_monoid (\sum_(j <- jobs_arrived_before arr_seq (t + d))
                             service_during sched j t (t + d)) (nat_of_bool false))
        with
          (addn_monoid (\sum_(j <- jobs_arrived_before arr_seq (t + d))
                         service_during sched j t (t + d)) 0); auto. symmetry.
      apply idle_last_instant. rewrite -> negbFE; [auto | apply H].
      Qed.

  End Lemmas.

End TotalService.