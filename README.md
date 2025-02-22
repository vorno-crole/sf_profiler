# sf_profiler
Salesforce Governor Limits Profiler


## Instructions

At start of trigger op, construct instance
```
VC_Profiler profiler = new VC_Profiler('Incident', 'BeforeUpdate');
```

then, before each calling method
```
profiler.measureStart('methodNameA');
```

and, after each calling method
```
profiler.measureStop('methodNameA');
```

and, at the end of the trigger op, end measurement
```
profiler.endMeasure();
```

anytime you can check limits
```
profiler.debugLimits();
```

once code has been added, turn on debug logs, run your code/triggers
and search log for reg ex:
```
USER_DEBUG\|\[\d+\]\|DEBUG\|VC_Profiler
```

