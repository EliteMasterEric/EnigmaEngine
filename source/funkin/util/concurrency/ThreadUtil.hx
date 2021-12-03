package funkin.util.concurrency;

class ThreadUtil
{
	public static function doInBackground(cb:Void->Void)
	{
		#if threads
		sys.thread.Thread.create(() ->
		{
			// Run in the background.
			cb();
		});
		#else
		trace('WARNING: Tried to run callback with doInBackground, but multithreading is disabled on this platform.');
		cb();
		#end
	}
}
