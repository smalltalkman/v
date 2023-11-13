import os
import log
import rand

fn test_reopen() {
	lfolder := os.join_path(os.vtmp_dir(), rand.ulid())
	lpath1 := os.join_path(lfolder, 'current.log')
	lpath2 := os.join_path(lfolder, 'current.log.2')
	os.mkdir_all(lfolder)!

	dump(lfolder)
	mut l := log.new_thread_safe_log()
	l.set_full_logpath(lpath1)
	l.warn('one warning')
	l.error('one error')
	// simulate a log rotation, by moving the log file
	os.mv(lpath1, lpath2)!
	l.warn('another warning')
	// call reopen, note that the message from above, should be in the new file lpath2:
	l.reopen()!
	l.warn('third warning')
	l.flush()
	l.close()
	// os.system('ls -la $lpath1 $lpath2')
	lcontent1 := os.read_file(lpath1)!
	lcontent2 := os.read_file(lpath2)!
	assert lcontent1.len > 0
	assert lcontent2.len > 0
	// the rotated log should have all messages before the l.reopen() call:
	assert lcontent2.contains('one warning')
	assert lcontent2.contains('one error')
	assert lcontent2.contains('another warning')
	// the log file that was reopened, should have only the new message:
	assert lcontent1.contains('third warning')
	assert !lcontent1.contains('one warning')

	os.rmdir_all(lfolder) or {}
}