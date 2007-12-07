/* Ruby-Dtrace
 * (c) 2007 Chris Andrews <chris@nodnol.org>
 */

#include "dtrace_api.h"

RUBY_EXTERN VALUE eDtraceException;
RUBY_EXTERN VALUE cDtraceAggData;
RUBY_EXTERN VALUE cDtraceRecDesc;

/* :nodoc: */
VALUE dtracebufdata_init(VALUE self)
{
  dtrace_bufdata_t *data;

  Data_Get_Struct(self, dtrace_bufdata_t, data);
  return self;
}

VALUE dtracebufdata_record(VALUE self)
{
  dtrace_bufdata_t *bufdata;
  const dtrace_recdesc_t *rec;
  dtrace_actkind_t act = DTRACEACT_NONE;
  const char *s;
  VALUE v = Qnil;
  VALUE dtracerecord;
  VALUE dtraceaggdata;
  VALUE dtracerecdesc;

  Data_Get_Struct(self, dtrace_bufdata_t, bufdata);
  
  if (bufdata->dtbda_aggdata) {
    dtraceaggdata = Data_Wrap_Struct(cDtraceAggData, 0, NULL, (dtrace_bufdata_t *)bufdata);
    return dtraceaggdata;
  }

  s = bufdata->dtbda_buffered;
  if (s == NULL) {
    return Qnil;
  }
  
  rec = bufdata->dtbda_recdesc;
  if (rec) {
    act = rec->dtrd_action;
  }
  
  switch (act) {
  case DTRACEACT_DIFEXPR:
    /* trace() action */
    break;
  case DTRACEACT_PRINTF:
    /*
     * Only the formatted string was not available to dtj_chewrec(),
     * so we attach that now.
     */
    v = rb_str_new2(s);
    break;
  case DTRACEACT_STACK:
  case DTRACEACT_USTACK:
  case DTRACEACT_JSTACK:
    /* stand-alone stack(), ustack(), or jstack() action */
    v = rb_str_new2(s);
    break;
  case DTRACEACT_USYM:
  case DTRACEACT_UADDR:
  case DTRACEACT_UMOD:
  case DTRACEACT_SYM:
  case DTRACEACT_MOD:
    v = rb_str_new2(s);
    break;
  case DTRACEACT_PRINTA:
    v = rb_str_new2(s);
    break;
  default:
    /*
     * The record handle defers nothing else to this
     * bufhandler.
     */
    break;
  }

  if (!NIL_P(v)) {
    dtracerecord = rb_class_new_instance(0, NULL, rb_path2class("DtraceRecord"));
    rb_iv_set(dtracerecord, "@value", v);
    return (dtracerecord);
  }
  else {
    return Qnil;
  }
}