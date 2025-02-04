#
# Copyright 2020 Google LLC.
#
# This software is provided as-is, without warranty or representation
# for any use or purpose. Your use of it is subject to your agreement with Google.

"""Custom operator that compares dictionaries in xcom.
"""

from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults


class CompareXComMapsOperator(BaseOperator):
  """Compare dictionary stored in xcom.

  Args:
    ref_task_ids: list of task ids from where the reference dictionary
        is fetched
    res_task_ids: list of task ids from where the comparing dictionary
        is fetched
  """

  @apply_defaults
  def __init__(
      self,
      ref_task_ids,
      res_task_ids,
      *args, **kwargs):
    super(CompareXComMapsOperator, self).__init__(*args, **kwargs)
    self.ref_task_ids = ref_task_ids
    self.res_task_ids = res_task_ids

  def execute(self, context):
    ref_obj = self.read_value_as_obj(self.ref_task_ids, context)
    res_obj = self.read_value_as_obj(self.res_task_ids, context)
    self.compare_obj(ref_obj, res_obj)
    return 'result contains the expected values'

  def read_value_as_obj(self, task_ids, context):
    ret_obj = {}
    for task_id in task_ids:
      value_str = context['ti'].xcom_pull(
          key=None,
          task_ids=task_id)
      self.parse_str_obj(value_str, ret_obj)
    return ret_obj

  def parse_str_obj(self, str_rep, obj):
    entries = str_rep.split('\n')
    for entry in entries:
      if entry:
        key, value = entry.split(': ')
        obj[key] = value

  def compare_obj(self, ref_obj, res_obj):
    if ref_obj != res_obj:
      raise ValueError(self.create_diff_str(ref_obj, res_obj))

  def create_diff_str(self, ref_obj, res_obj):
    msg = 'The result differs from the expected in the following ways:'
    for k in ref_obj:
      if k not in res_obj:
        msg = msg + ('\nmissing key: %s in result' % k)
      elif ref_obj[k] != res_obj[k]:
        msg = msg + ('\nexpected %s: %s but got %s: %s' % (
            k, ref_obj[k], k, res_obj[k]))
    for k in res_obj:
      if k not in ref_obj:
        msg = msg + ('\nunexpected key: %s in result' % k)
    return msg
