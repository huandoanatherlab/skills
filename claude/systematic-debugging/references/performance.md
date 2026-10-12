# Performance debugging

Use this playbook for slow responses, high CPU or memory, leaks, timeouts under load, or throughput drops.

## Measure first

- Pick one metric that matches the complaint: p50/p95 latency, throughput, peak memory, CPU time, or query count.
- Fix the conditions: environment, build mode, data size, warm or cold cache, concurrency.
- Record a baseline over several runs and note the variance. A change smaller than the variance is noise.

## Locate the bottleneck

Profile or trace; do not infer hot spots from reading code. Classify what dominates:

- CPU: hot loops, repeated work, inefficient algorithms, serialization;
- I/O: N+1 queries, missing indexes, unbatched calls, chatty network round trips;
- waiting: locks, connection or thread pool exhaustion, rate limits;
- memory: allocation churn, GC pressure, unbounded caches or growing collections.

Find when it started with history or bisection when a regression is suspected.

## Change and compare

Change one thing, then measure again the same way. Report results as before → after with the metric and run count. Keep a change only if it beats the variance and keeps behavior correct.

## Verify

Re-run the original scenario and the relevant correctness tests. For leaks and load issues, run long enough or at enough load to show the trend has stopped, not one quick pass.
