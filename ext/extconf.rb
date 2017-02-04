require 'mkmf'
require 'rbconfig'

if CONFIG['CC'] =~ /gcc/
  $CFLAGS << ' -pedantic -Wall'
end

$defs.push("-DUSE_TBR")
$defs.push("-DHAVE_THREAD_H") if have_header('ruby/thread.h')
$defs.push("-DHAVE_TBR") if have_func('rb_thread_blocking_region', 'ruby.h')
$defs.push("-DHAVE_TCWOGVL") if have_header('ruby/thread.h') && have_func('rb_thread_call_without_gvl', 'ruby/thread.h')

create_makefile 'magvar'
