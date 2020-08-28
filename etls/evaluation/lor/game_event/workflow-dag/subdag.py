#
# Copyright 2020 Google LLC.
#
# This software is provided as-is, without warranty or representation
# for any use or purpose. Your use of it is subject to your agreement with Google.

"""
Dag File(This one): subdag.py
Purpose: Orchestrate GameEvent BigQuery SQL Scripts in Apache Airflow and develop ETL pipeline.
         checkpoints are integrated in Dag for tables existence and create if not exists.
         Data Recovery steps are executed at every table load step in case of failure.

Input: Date
Expected Output: GameEvent ETL Pipeline
"""

import os

from airflow.models import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.contrib.operators.bigquery_operator import BigQueryCreateEmptyTableOperator, BigQueryOperator
from airflow.utils.trigger_rule import TriggerRule
from airflow.operators.python_operator import PythonOperator, BranchPythonOperator

from google.cloud import storage, bigquery

def if_tbl_exists(dataset,project,table_name):
    from google.cloud.exceptions import NotFound
    client = bigquery.Client()
    os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = '/Users/ext.gampapathini/Airflow/dags/cicd/lor-data-platform-dev-f369-0c3a4fcdd405.json'

    try:
        client.get_table(project+'.'+dataset+'.'+table_name)
        print('table exist')
        return '%s-%s' % (table_name,"table_exists")
    except NotFound:
        print('table not exist')
        return '%s-%s' % (table_name,"check_if_table_exist")

def dag_preprocess(dag_id,
                   schedule_interval,
                   start_date,
                   source_project_id,
                   source_dataset_id,
                   target_project_id,
                   target_dataset_id,
                   table_config,
                   date_partition
                   ):
    dag = DAG(
        dag_id=dag_id,
        schedule_interval=schedule_interval,
        start_date=start_date)


    for table in table_config:

        start_extract_load_task = DummyOperator(task_id='%s-%s' % ("start_extract_load_task",table["name"]),
                                                dag=dag)

        remove_date_partitioned_data_before_insert = BigQueryOperator(
            task_id='%s-%s' % (table["name"],"remove_date_partitioned_data_before_insert"),
            bql = "DELETE FROM " + target_project_id + '.' + target_dataset_id + '.' + table["name"] + " WHERE PARTITION_DATE = '" +date_partition+"'" ,
            use_legacy_sql = False,
            trigger_rule=TriggerRule.NONE_FAILED_OR_SKIPPED,
            dag=dag
        )

        # [START howto_operator_bigquery_upsert_table]
        update_item_ref_table = BigQueryOperator(
            task_id='%s-%s' % ("update_table",table["name"]),
            sql= table["loadscript"],
            destination_dataset_table=target_project_id + '.' + target_dataset_id + '.' + table["name"],
            write_disposition='WRITE_APPEND',
            params={"dt_value":date_partition,
                    "source_project_id":source_project_id,
                    "source_dataset_name":source_dataset_id,
                    "target_project_id":target_project_id,
                    "target_dataset_name":target_dataset_id},
            use_legacy_sql=False,
            trigger_rule=TriggerRule.NONE_FAILED_OR_SKIPPED,
            dag=dag
        )

        update_success = DummyOperator(
            task_id='%s-%s' % (table["name"],"update_success"),
            trigger_rule=TriggerRule.NONE_FAILED_OR_SKIPPED,
            dag=dag)

        update_failure = DummyOperator(
            task_id='%s-%s' % (table["name"],"update_failure"),
            trigger_rule=TriggerRule.ALL_FAILED,
            dag=dag)

        copy_backup_table = BigQueryOperator(
            task_id='%s-%s' % ("copy_backup_table", table["name"]),
            sql="SELECT * FROM "  + target_project_id + '.' + target_dataset_id + '.' + table["name"] + " FOR SYSTEM_TIME AS OF TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR) WHERE PARTITION_DATE = '" +date_partition+"'",
            destination_dataset_table=target_project_id + '.' + target_dataset_id + '.' + table["name"],
            write_disposition='WRITE_APPEND',
            params={"dt_value":date_partition},
            use_legacy_sql=False,
            trigger_rule=TriggerRule.ONE_FAILED,
            dag=dag
        )

        end_extract_load_task = DummyOperator(task_id='%s-%s' % ("end_extract_load_task",table["name"]),
                                              trigger_rule='none_failed_or_skipped',
                                              dag=dag)

        start_extract_load_task >> remove_date_partitioned_data_before_insert >> update_item_ref_table >> [update_success, update_failure]
        update_failure >> copy_backup_table >> end_extract_load_task
        update_success >> end_extract_load_task

    return dag


def dag_preprocess_tables(dag_id,
                          schedule_interval,
                          start_date,
                          target_project_id,
                          target_dataset_id,
                          table_config,
                          table_partition,
                          ):
    dag = DAG(
        dag_id=dag_id,
        schedule_interval=schedule_interval,
        start_date=start_date)

    for table in table_config:

        start_check_tables_task = DummyOperator(task_id='%s-%s' % ("start_check_tables_task",table["name"]),
                                                dag=dag)

        check_if_table_exist = BranchPythonOperator(
            task_id='%s-%s' % (table["name"],"check_if_table_exist"),
            python_callable=if_tbl_exists,
            op_kwargs={'dataset': target_dataset_id, 'project':target_project_id,'table_name':table["name"]},
            dag=dag
        )

        table_exists = DummyOperator(
            task_id='%s-%s' % (table["name"],"table_exists"),
            dag=dag)

        table_does_not_exist = DummyOperator(
            task_id='%s-%s' % (table["name"],"table_does_not_exist"),
            dag=dag)

        # [start create equipped_item_reference if not exists]
        create_if_not_exists = BigQueryCreateEmptyTableOperator(
            task_id='%s-%s' % (table["name"],"create_if_not_exists"),
            project_id=target_project_id,
            dataset_id=target_dataset_id,
            table_id=table["name"],
            gcs_schema_object=table["schema_gcs_location"],
            time_partitioning=table_partition,
            trigger_rule=TriggerRule.ALL_SUCCESS,
            dag=dag
        )

        end_check_tables_task = DummyOperator(task_id='%s-%s' % ("end_check_tables_task", table["name"]),
                                              trigger_rule='none_failed_or_skipped',
                                              dag=dag)

        start_check_tables_task >> check_if_table_exist >> [table_does_not_exist, table_exists]
        table_does_not_exist >> create_if_not_exists >> end_check_tables_task
        table_exists >> end_check_tables_task

    return dag



