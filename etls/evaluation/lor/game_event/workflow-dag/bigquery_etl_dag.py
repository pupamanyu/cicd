#
# Copyright 2020 Google LLC.
#
# This software is provided as-is, without warranty or representation
# for any use or purpose. Your use of it is subject to your agreement with Google.

"""
Dag File(This one): bigquery_etl_dag.py
Purpose: Orchestrate GameEvent BigQuery SQL Scripts in Apache Airflow and develop ETL pipeline.
         checkpoints are integrated in Dag for tables existence and create if not exists.
         Data Recovery steps are executed at every table load step in case of failure.

Input: Date
Expected Output: GameEvent ETL Pipeline
"""
import os
import sys
import datetime as dt

from airflow import models
from airflow.operators.subdag_operator import SubDagOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.models import Variable
from airflow.contrib.operators.bigquery_operator import BigQueryCreateEmptyTableOperator, BigQueryOperator
from airflow.utils.dates import days_ago
from airflow.executors.celery_executor import CeleryExecutor

sys.path.insert(0,os.path.abspath(os.path.dirname(__file__)))
from subdag import dag_preprocess, dag_preprocess_tables


# Config variables
# Airflow Variables are stored in Metadata Database, so any call to variables would mean a connection to Metadata DB.
# Your DAG files are parsed every X seconds. Using a large number of variable in your DAG (and worse in default_args)
# may mean you might end up saturating the number of allowed connections to your database.
# To avoid this situation, use a single Airflow variable with JSON value.
DEFAULT_DAG_ARGS = {'start_date': dt.datetime.now()}
input_date = "2020-07-26"

dag_config = Variable.get("lor_game_event_test", deserialize_json=True)
TARGET_PROJECT_ID = dag_config["target_project_id"]
TARGET_DATASET_NAME = dag_config["target_dataset_name"]
SOURCE_PROJECT_ID = dag_config["source_project_id"]
SOURCE_DATASET_NAME = dag_config["source_dataset_name"]
TABLES = dag_config["tables"]

NO_DEPENDENCY_TABLES = []
TABLE_PLAYER_LOCATION_DAILY = []
TABLE_SESSION_EVENT_START = []
TABLE_GAME_EVENT = []

for table in TABLES:
    no_dependency={}
    if table['name'] == "equipped_item_reference_daily" or \
            table['name'] == "clean_game_start" or \
            table['name'] == "clean_game_end" or \
            table['name'] == "clean_queue_result":
        no_dependency['name']=table['name']
        no_dependency['schema_gcs_location']=table['schema_gcs_location']
        no_dependency['loadscript']=table['loadscript']
        NO_DEPENDENCY_TABLES.append(no_dependency)

    player_location_daily={}
    if table['name'] == "player_location_daily":
        player_location_daily['name']=table['name']
        player_location_daily['schema_gcs_location']=table['schema_gcs_location']
        player_location_daily['loadscript']=table['loadscript']
        TABLE_PLAYER_LOCATION_DAILY.append(player_location_daily)

    session_start_event={}
    if table['name'] == "session_start_event":
        session_start_event['name']=table['name']
        session_start_event['schema_gcs_location']=table['schema_gcs_location']
        session_start_event['loadscript']=table['loadscript']
        TABLE_SESSION_EVENT_START.append(session_start_event)

    game_event={}
    if table['name'] == "game_event":
        game_event['name']=table['name']
        game_event['schema_gcs_location']=table['schema_gcs_location']
        game_event['loadscript']=table['loadscript']
        TABLE_GAME_EVENT.append(game_event)

DAG_ID = 'lor-game-event'

with models.DAG(DAG_ID,
                schedule_interval=None,  # Override to match your needs
                start_date=days_ago(1),
                tags=["lor"],
                default_args=DEFAULT_DAG_ARGS,
                params={'source_project_id': SOURCE_PROJECT_ID,
                        'source_dataset_name': SOURCE_DATASET_NAME,
                        'target_project_id': TARGET_PROJECT_ID,
                        'target_dataset_name': TARGET_DATASET_NAME,
                        'input_date':input_date}) as dag:

    start_game_event_task = DummyOperator(task_id='start_game_event_task',
                                          dag=dag)

    # Dag Task to check the BigQuery connection
    check_bigquery_connection = BigQueryOperator(task_id='check_bigquery_connection',
                                                 bql='SELECT 1', use_legacy_sql=False,
                                                 # Set a connection ID to use a connection that you have created.
                                                 bigquery_conn_id='bigquery_default',
                                                 dag=dag
                                                 )

    # SubDag Task to check if the required tables exist in BigQuery.
    # Table is created if table does not exist.
    preprocess_check_create_tables_if_not_exists = SubDagOperator(task_id='preprocess_check_create_tables_if_not_exists',
                                                                  subdag=dag_preprocess_tables('%s.%s' % (DAG_ID, 'preprocess_check_create_tables_if_not_exists'),
                                                                                               dag.schedule_interval,
                                                                                               DEFAULT_DAG_ARGS['start_date'],
                                                                                               TARGET_PROJECT_ID,
                                                                                               TARGET_DATASET_NAME,
                                                                                               TABLES,
                                                                                               '{"type": "DAY", "field": "partition_date"}'),
                                                                  dag=dag)

    # Dag Task to load independent tables parallely.

    load_no_dependency_tables = SubDagOperator( executor=CeleryExecutor(),
                                                task_id='load_no_dependency_tables',
                                                subdag=dag_preprocess('%s.%s' % (DAG_ID, 'load_no_dependency_tables'),
                                                                      dag.schedule_interval,
                                                                      DEFAULT_DAG_ARGS['start_date'],
                                                                      SOURCE_PROJECT_ID,
                                                                      SOURCE_DATASET_NAME,
                                                                      TARGET_PROJECT_ID,
                                                                      TARGET_DATASET_NAME,
                                                                      NO_DEPENDENCY_TABLES,
                                                                      input_date),

                                                dag=dag)

    load_session_start_event = SubDagOperator(  executor=CeleryExecutor(),
                                                task_id='load_session_start_event',
                                                subdag=dag_preprocess('%s.%s' % (DAG_ID, 'load_session_start_event'),
                                                                      dag.schedule_interval,
                                                                      DEFAULT_DAG_ARGS['start_date'],
                                                                      SOURCE_PROJECT_ID,
                                                                      SOURCE_DATASET_NAME,
                                                                      TARGET_PROJECT_ID,
                                                                      TARGET_DATASET_NAME,
                                                                      TABLE_SESSION_EVENT_START,
                                                                      input_date),
                                                dag=dag)

    load_player_location_daily = SubDagOperator(executor=CeleryExecutor(),
                                                task_id='load_player_location_daily',
                                                subdag=dag_preprocess('%s.%s' % (DAG_ID, 'load_player_location_daily'),
                                                                      dag.schedule_interval,
                                                                      DEFAULT_DAG_ARGS['start_date'],
                                                                      SOURCE_PROJECT_ID,
                                                                      SOURCE_DATASET_NAME,
                                                                      TARGET_PROJECT_ID,
                                                                      TARGET_DATASET_NAME,
                                                                      TABLE_PLAYER_LOCATION_DAILY,
                                                                      input_date),
                                                dag=dag)


    load_game_event = SubDagOperator(executor=CeleryExecutor(),
                                     task_id='load_game_event',
                                     subdag=dag_preprocess('%s.%s' % (DAG_ID, 'load_game_event'),
                                                           dag.schedule_interval,
                                                           DEFAULT_DAG_ARGS['start_date'],
                                                           SOURCE_PROJECT_ID,
                                                           SOURCE_DATASET_NAME,
                                                           TARGET_PROJECT_ID,
                                                           TARGET_DATASET_NAME,
                                                           TABLE_GAME_EVENT,
                                                           input_date),
                                     dag=dag)

    end_game_event_task = DummyOperator(task_id='end_game_event_task',trigger_rule='none_failed_or_skipped',
                                        dag=dag)

    start_game_event_task >> check_bigquery_connection >> preprocess_check_create_tables_if_not_exists >> [load_no_dependency_tables,
                                                                                                           load_session_start_event]
    load_no_dependency_tables >> load_game_event >> end_game_event_task

    load_session_start_event >> load_player_location_daily >> load_game_event >> end_game_event_task
