/*
 * Apache License, Version 2.0
 *
 * Copyright (c) 2021 MasterEric
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * TaskWorker.hx, aka "Alfred"
 * "Right away, Master Bruce."
 * 
 * Creates and manages an asynchronous task executor.
 * 
 * On platforms with thread support, true concurrent execution is supported.
 * On platforms without thread support, tasks will merely be run asynchronously.
 *   This is still useful as it prevents the program from hanging while performing tasks.
 */
package funkin.util.concurrency;

import hx.concurrent.executor.Executor;
import hx.concurrent.executor.Schedule;

class TaskWorker
{
	// We're using a pool of three threads for now.
	static final THREAD_COUNT = 3;
	// Eagerly create a single instance of the executor that is shared by all tasks.
	private static final executor = Executor.create(3);

	/**
	 * Sch
	 * @param task This is just a function with no parameters. May optionally return a value.
	 * @param schedule Optional argument to specify delayed or periodic execution.
	 *   Defaults to immediate one-time execution.
	 * 	 See: https://github.com/vegardit/haxe-concurrent/blob/main/src/hx/concurrent/executor/Schedule.hx
	 * @return A Future, which allows you to determine the current state of the task,
	 *  or to cancel pending/periodic tasks.
	 */
	public static function performTask<T>(task:Task<T>, ?schedule:Schedule):TaskFuture<T>
	{
		return executor.submit(task, schedule);
	}

	/**
	 * Convenience function which performs a task after a delay.
	 * @param task A function with no parameters. May optionally return a value.
	 * @param delay The number of milliseconds to wait before executing the task.
	 * @return Hold onto this object to cancel the task, check its state, or retrieve the result.
	 */
	public static function performTaskWithDelay<T>(task:Task<T>, delay:Int = 0):TaskFuture<T>
	{
		return performTask(task, Schedule.ONCE(delay));
	}

	/**
	 * Convenience function which performs a task on a periodic basis.
	 * @param task A function with no parameters. May optionally return a value.
	 * @param period The number of milliseconds to wait between each execution of the task.
	 * @return Hold onto this object to cancel the task, check its state, or retrieve the result.
	 */
	public static function performTaskWithPeriod<T>(task:Task<T>, period:Int = 0):TaskFuture<T>
	{
		return performTask(task, Schedule.FIXED_RATE(period));
	}
}
