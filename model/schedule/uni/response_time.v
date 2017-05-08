Require Import rt.util.all.
Require Import rt.model.arrival.basic.task rt.model.arrival.basic.job rt.model.arrival.basic.task_arrival.
Require Import rt.model.schedule.uni.schedule.
From mathcomp Require Import ssreflect ssrbool eqtype ssrnat seq fintype bigop.

Module ResponseTime.

  Import UniprocessorSchedule SporadicTaskset TaskArrival.

  (* In this section, we define the notion of a response-time bound. *)
  Section ResponseTimeBound.

    Context {sporadic_task: eqType}.
    Context {Job: eqType}.
    Variable job_arrival: Job -> time.
    Variable job_cost: Job -> time.
    Variable job_task: Job -> sporadic_task.

    (* Consider any job arrival sequence... *)
    Variable arr_seq: arrival_sequence Job.

    (* ...and any uniprocessor schedule of these jobs. *)
    Variable sched: schedule Job.

    (* Let tsk be any task that is to be analyzed. *)
    Variable tsk: sporadic_task.

    (* For simplicity, let's define some local names. *)
    Let job_has_completed_by := completed_by job_cost sched.

    (* Then, we say that R is a response-time bound of tsk in this schedule ... *)
    Variable R: time.

    (* ... iff any job j of tsk in this arrival sequence has
       completed by (job_arrival j + R). *)
    Definition is_response_time_bound_of_task :=
      forall j,
        arrives_in arr_seq j ->
        job_task j = tsk ->
        job_has_completed_by j (job_arrival j + R).
        
  End ResponseTimeBound.

  (* In this section, we prove some basic lemmas about response-time bounds. *)
  Section BasicLemmas.

    Context {sporadic_task: eqType}.
    Context {Job: eqType}.
    Variable job_arrival: Job -> time.
    Variable job_cost: Job -> time.
    Variable job_task: Job -> sporadic_task.
    
    (* Consider any job arrival sequence... *)
    Variable arr_seq: arrival_sequence Job.

    (* ...and any uniprocessor schedule of these jobs. *)
    Variable sched: schedule Job.

    (* Assume that jobs don't execute after completion. *)
    Hypothesis H_completed_jobs_dont_execute:
      completed_jobs_dont_execute job_cost sched.

    (* For simplicity, let's define some local names. *)
    Let job_has_completed_by := completed_by job_cost sched.

    (* We begin by proving lemmas about job response-time bounds. *)
    Section SpecificJob.

      (* Let j be any job... *)
      Variable j: Job.
      
      (* ...with response-time bound R. *)
      Variable R: time.
      Hypothesis response_time_bound:
        job_has_completed_by j (job_arrival j + R). 

      (* Then, the service received by j at any time t' after its response time is 0. *)
      Lemma service_after_job_rt_zero :
        forall t',
          t' >= job_arrival j + R ->
          service_at sched j t' = 0.
      Proof.
        rename response_time_bound into RT,
               H_completed_jobs_dont_execute into EXEC; ins.
        unfold is_response_time_bound_of_task, completed_by,
               completed_jobs_dont_execute in *.
        apply/eqP; rewrite -leqn0.
        rewrite <- leq_add2l with (p := job_cost j).
        move: RT => /eqP RT; rewrite -{1}RT addn0.
        apply leq_trans with (n := service sched j t'.+1);
          last by apply EXEC.
        unfold service, service_during.
        rewrite -> big_cat_nat with (p := t'.+1) (n := job_arrival j + R);
          [rewrite leq_add2l /= | by ins | by apply ltnW].
        by rewrite big_nat_recr // /=; apply leq_addl.
      Qed.

      (* The same applies for the cumulative service of job j. *)
      Lemma cumulative_service_after_job_rt_zero :
        forall t' t'',
          t' >= job_arrival j + R ->
          \sum_(t' <= t < t'') service_at sched j t = 0.
      Proof.
        ins; apply/eqP; rewrite -leqn0.
        rewrite big_nat_cond; rewrite -> eq_bigr with (F2 := fun i => 0);
          first by rewrite big_const_seq iter_addn mul0n addn0 leqnn.
        intro i; rewrite andbT; move => /andP [LE _].
        by rewrite service_after_job_rt_zero;
          [by ins | by apply leq_trans with (n := t')].
      Qed.
      
    End SpecificJob.

    (* Next, we prove properties about task response-time bounds. *)
    Section AllJobs.

      (* Consider any task tsk ...*)
      Variable tsk: sporadic_task.

      (* ... for which a response-time bound R is known. *)
      Variable R: time.
      Hypothesis response_time_bound:
        is_response_time_bound_of_task job_arrival job_cost job_task arr_seq sched tsk R.

      (* Then, for any job j of this task, ...*)
      Variable j: Job.
      Hypothesis H_from_arrival_sequence: arrives_in arr_seq j.
      Hypothesis H_job_of_task: job_task j = tsk.

      (* ...the service received by job j at any time t' after the response time is 0. *)
      Lemma service_after_task_rt_zero :
        forall t',
          t' >= job_arrival j + R ->
          service_at sched j t' = 0.
      Proof.
        intros t' LE.
        apply service_after_job_rt_zero with (R := R); last by done.
        by apply response_time_bound.
      Qed.

      (* The same applies for the cumulative service of job j. *)
      Lemma cumulative_service_after_task_rt_zero :
        forall t' t'',
          t' >= job_arrival j + R ->
          \sum_(t' <= t < t'') service_at sched j t = 0.
      Proof.
        by ins; apply cumulative_service_after_job_rt_zero with (R := R);
          first by apply response_time_bound. 
      Qed.
      
    End AllJobs.

  End BasicLemmas.
    
End ResponseTime.