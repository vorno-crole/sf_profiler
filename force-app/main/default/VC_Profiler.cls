/*
 * Copyright (c) 2025 Vaughan Crole vc@vaughancrole.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
 * to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, 
 * sublicense, and/ or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 * MERCHANTABILITY,  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
 * FOR ANY CLAIM, DAMAGES OR OTHER  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 */
public without sharing class VC_Profiler
{
	public VC_Profiler(String argObjName, String triggerOperation)
	{
		// System.debug(argObjName + ': ' + triggerOperation);

		objName   = argObjName;
		triggerOp = 'Trigger.' + argObjName + '.' + triggerOperation;

		recordLimitStart(triggerOp, null);
	}

	private Map<String, currentLimit> LimitMeasurements;
	private Map<String, limitsSpent>  LimitsSpend;
	private String objName;
	private String triggerOp;


	// ************************************************************************************
	// *** Instructions:
	//
	// At start of trigger op, construct instance
	// 		VC_Profiler profiler = new VC_Profiler('Incident', 'BeforeUpdate');

	// then, before each calling method
	//		profiler.measureStart('methodNameA');
	
	// and, after each calling method
	//		profiler.measureStop('methodNameA');

	// and, at the end of the trigger op, end measurement
	//		profiler.endMeasure();

	// anytime you can check limits
	//		profiler.debugLimits();

	// once code has been added, turn on debug logs, run your code/triggers
	// and search log for reg ex:
	// USER_DEBUG\|\[\d+\]\|DEBUG\|VC_Profiler


	// ************************************************************************************
	// *** Limits methods:

	public static Integer getDMLRowsLeft()
	{
		return Limits.getLimitDMLRows() - Limits.getDMLRows();
	}

	public static Integer getQueryRowsLeft()
	{
		return Limits.getLimitQueryRows() - Limits.getQueryRows();
	}

	public static Integer getDMLStatementsLeft()
	{
		return Limits.getLimitDMLStatements() - Limits.getDMLStatements();
	}

	public static Integer getQueriesLeft()
	{
		return Limits.getLimitQueries() - Limits.getQueries();
	}

	public static Integer getFutureCallsLeft()
	{
		return Limits.getLimitFutureCalls() - Limits.getFutureCalls();
	}

	public static currentLimit getMeasure()
	{
		return getMeasure(null);
	}

	public static currentLimit getMeasure(Integer idx)
	{
		currentLimit cl = new currentLimit();
		cl.dmlRowsLeft = getDMLRowsLeft();
		cl.dmlStatementsLeft = getDMLStatementsLeft();
		cl.queryRowsLeft = getQueryRowsLeft();
		cl.queriesLeft = getQueriesLeft();
		cl.futureCallsLeft = getFutureCallsLeft();

		if (idx != null) cl.index = idx;

		return cl;
	}

	private void recordLimitStart(String key, Integer index)
	{
		if (LimitMeasurements == null)
			LimitMeasurements = new Map<String, currentLimit>();

		if (LimitMeasurements.containsKey(key))
		{
			// warning?
		}

		System.debug('VC_Profiler Measurement start: ' + key);
		LimitMeasurements.put(key, getMeasure(index));
	}

	private limitsSpent recordLimitEnd(String key)
	{
		if (LimitMeasurements == null)
			LimitMeasurements = new Map<String, currentLimit>();

		if (!LimitMeasurements.containsKey(key))
		{
			// error
			return null;
		}

		currentLimit cl_prior = LimitMeasurements.get(key);
		currentLimit cl_now   = getMeasure();

		limitsSpent spend = new limitsSpent(cl_prior, cl_now);
		spend.name = key;
		spend.triggerOp = triggerOp;

		if (LimitsSpend == null)
			LimitsSpend = new Map<String, limitsSpent>();

		LimitsSpend.put(key, spend);
		LimitMeasurements.remove(key);

		System.debug('VC_Profiler Measurement end: ' + JSON.serializePretty(spend));
		return spend;
	}

	public void measureStart(String methodName)
	{
		measureStart(methodName, null);
	}

	public void measureStart(String methodName, Integer index)
	{
		recordLimitStart(objName + '.' + methodName, index);
	}

	public limitsSpent measureStop(String methodName)
	{
		return recordLimitEnd(objName + '.' + methodName);
	}

	public limitsSpent endMeasure()
	{
		return recordLimitEnd(triggerOp);
	}

	public static void debugLimits()
	{
		System.debug(JSON.serializePretty(getMeasure()));
	}

	public class currentLimit
	{
		public Integer index;
		public Integer dmlRowsLeft       = 0;
		public Integer dmlStatementsLeft = 0;
		public Integer queryRowsLeft     = 0;
		public Integer queriesLeft       = 0;
		public Integer futureCallsLeft   = 0;
	}

	public class limitsSpent
	{
		public limitsSpent() {}
		public limitsSpent(currentLimit cl_prior, currentLimit cl_now)
		{
			if (cl_prior == null || cl_now == null)
				return;

			dmlRows       = (cl_prior.dmlRowsLeft ?? 0)       - (cl_now.dmlRowsLeft ?? 0);
			dmlStatements = (cl_prior.dmlStatementsLeft ?? 0) - (cl_now.dmlStatementsLeft ?? 0);
			queryRows     = (cl_prior.queryRowsLeft ?? 0)     - (cl_now.queryRowsLeft ?? 0);
			queries       = (cl_prior.queriesLeft ?? 0)       - (cl_now.queriesLeft ?? 0);
			futureCalls   = (cl_prior.futureCallsLeft ?? 0)   - (cl_now.futureCallsLeft ?? 0);

			index = cl_prior.index;
		}

		public String  name;
		public String  triggerOp;
		public Integer index;
		public Integer dmlRows       = 0;
		public Integer dmlStatements = 0;
		public Integer queryRows     = 0;
		public Integer queries       = 0;
		public Integer futureCalls   = 0;
	}



}
