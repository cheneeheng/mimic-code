"""Exports data from SQL database into json files. """

import getpass
import json
import math
import os
import psycopg2
import pandas as pd
import time

from configobj import ConfigObj
from multiprocessing import Pool, RLock
from tqdm import tqdm
from typing import Tuple

from projects import *

__all__ = ['connect_to_database', 'get_id_list', 'get_table']


def connect_to_database(db_path: str) -> Tuple[str, str, str,
                                               psycopg2.extensions.connection]:
    """Connect to the SQL database. """

    # Create a database connection using settings from config file
    config = os.path.join(db_path, 'config.ini')

    # connection info
    conn_info = dict()
    if os.path.isfile(config):
        config = ConfigObj(config)
        conn_info["sqluser"] = config['username']
        conn_info["sqlpass"] = config['password']
        conn_info["sqlhost"] = config['host']
        conn_info["sqlport"] = config['port']
        conn_info["dbname"] = config['dbname']
        conn_info["schema_name_core"] = config['schema_name_core']
        conn_info["schema_name_hosp"] = config['schema_name_hosp']
        conn_info["schema_name_icu"] = config['schema_name_icu']
        conn_info["schema_name_derived"] = config['schema_name_derived']
    else:
        conn_info["sqluser"] = 'postgres'
        conn_info["sqlpass"] = ''
        conn_info["sqlhost"] = 'localhost'
        conn_info["sqlport"] = 5432
        conn_info["dbname"] = 'mimiciv'
        conn_info["schema_name_core"] = 'public,mimic_core'
        conn_info["schema_name_hosp"] = 'public,mimic_hosp'
        conn_info["schema_name_icu"] = 'public,mimic_icu'
        conn_info["schema_name_derived"] = 'public,mimic_derived'

    # Connect to the eICU database
    print('Database: {}'.format(conn_info['dbname']))
    print('Username: {}'.format(conn_info["sqluser"]))

    if conn_info["sqlpass"] == '':
        # try connecting without password, i.e. peer or OS authentication
        try:
            if ((conn_info["sqlhost"] == 'localhost') &
                (conn_info["sqlport"] == '5432')):  # noqa
                conn = psycopg2.connect(dbname=conn_info["dbname"],
                                        user=conn_info["sqluser"])
            else:
                conn = psycopg2.connect(dbname=conn_info["dbname"],
                                        host=conn_info["sqlhost"],
                                        port=conn_info["sqlport"],
                                        user=conn_info["sqluser"])
        except:  # noqa
            conn_info["sqlpass"] = getpass.getpass('Password: ')

            conn = psycopg2.connect(dbname=conn_info["dbname"],
                                    host=conn_info["sqlhost"],
                                    port=conn_info["sqlport"],
                                    user=conn_info["sqluser"],
                                    password=conn_info["sqlpass"])

    else:
        conn = psycopg2.connect(dbname=conn_info["dbname"],
                                host=conn_info["sqlhost"],
                                port=conn_info["sqlport"],
                                user=conn_info["sqluser"],
                                password=conn_info["sqlpass"])

    def _f(x):
        return 'set search_path to ' + x + ';'

    query_schema_core = _f(conn_info['schema_name_core'])
    query_schema_hosp = _f(conn_info['schema_name_hosp'])
    query_schema_icu = _f(conn_info['schema_name_icu'])
    query_schema_derived = _f(conn_info['schema_name_derived'])

    print(">>>>> Connected to DB <<<<<")

    return (query_schema_core, query_schema_hosp, query_schema_icu,
            query_schema_derived, conn)


def get_id_list(_conn: psycopg2.extensions.connection,
                _query_schema: str,
                _table: str,
                _main_col: str) -> list:
    """Get the list of ids."""

    assert _table in ['patients', 'transfers', 'admissions', 'icustays']

    print(f"Getting {_table} data")

    # if UNIT_TYPES_SQL is not None:
    #     query = query_schema + """
    #     select *
    #     from patient
    #     where unitType in {}
    #     """.format(UNIT_TYPES_SQL)
    # else:
    query = _query_schema + f"""
    select *
    from {_table}
    """
    df = pd.read_sql_query(query, _conn)
    df.sort_values(_main_col, ascending=True, inplace=True)
    df.drop_duplicates(subset=[_main_col])

    print(f"Number of entries for {_table} : {df.shape[0]}")

    return df[_main_col].tolist()


def get_table(_conn: psycopg2.extensions.connection,
              _query_schema: str,
              _table: str,
              _col: str = None,
              _chunk_size: int = None) -> pd.DataFrame:
    """Get the data in `_table`."""

    print(f"Getting {_table} data")

    query = _query_schema + f"""
    select {'*' if _col is None else _col}
    from {_table}
    """

    if _chunk_size is None:
        df = pd.read_sql_query(query, _conn, chunksize=_chunk_size)
        # df.sort_values('intime', ascending=True, inplace=True)
        # assert len(df[df.duplicated(['stay_id'])]) == 0
        print(f"Number of entries for {_table} : {df.shape[0]}")
        print(f"Column names : {df.columns.tolist()}")

    else:
        num_entries, col_names = 0, None
        df_iter = pd.read_sql_query(query, _conn, chunksize=_chunk_size)
        for chunk in tqdm(df_iter):
            num_entries += len(chunk)
            if col_names is None:
                col_names = chunk.columns.tolist()
        print(f"Number of entries for {_table} : {num_entries}")
        print(f"Column names : {col_names}")
        df = pd.read_sql_query(query, _conn, chunksize=_chunk_size)

    return df


def get_multiple_data_and_save(output_folder,
                               patientunitstayid_list=[],
                               pid=0):
    """
    Iterates over `patientunitstayid` and saves entries from all tables
    with the similar id into json.
    """

    query_schema, conn = connect_to_database()

    pbar = tqdm(patientunitstayid_list, position=pid+1)
    for patientunitstayid in pbar:

        time.sleep(1)
        pbar.set_description(f"Processing {patientunitstayid}")

        json_dict = {}

        for table_name in TABLE_LIST:

            query = query_schema + """
            select *
            from {}
            where patientunitstayid = {}
            """.format(table_name, patientunitstayid)
            df = pd.read_sql_query(query, conn)

            label = df.columns.to_list()

            json_dict[table_name] = {}
            for label_i in label:
                json_dict[table_name][label_i] = df[label_i].tolist()

        json_path = f"{output_folder}/{patientunitstayid}.json"
        with open(json_path, 'w') as json_file:
            json.dump(json_dict, json_file)

    conn.close()


if __name__ == "__main__":

    (query_schema_core,
     query_schema_hosp,
     query_schema_icu,
     query_schema_derived,
     conn) = connect_to_database("db")

    # # list of subjects available in the database.
    # subject_ids = get_id_list(query_schema_core, 'patients', 'subject_id')

    # # list of amission available in the database.
    # hadm_ids = get_id_list(query_schema_core, 'admissions', 'hadm_id')

    # # list of transfers in the database.
    # transfer_ids = get_id_list(query_schema_core, 'transfers', 'transfer_id')

    # icusstays table as pd.Dataframe.
    # icu_stays_df = get_icu_stays(conn, query_schema_icu)

    # interval = 1

    # for i in range(MP_CHUNK_START, MP_CHUNK_SIZE, interval):

    #     x = npi(patientunitstayid_list) * i
    #     y = npi(patientunitstayid_list) * (i + interval)
    #     list_i = patientunitstayid_list[x:y]

    #     output_folder = os.path.join(DB_EXPORT_PATH, f'{i}')
    #     os.makedirs(output_folder, exist_ok=True)
    #     parallel_processing(get_multiple_data_and_save,
    #                         MP_NUM_PROCESSES,
    #                         output_folder,
    #                         list_i)

    conn.close()
