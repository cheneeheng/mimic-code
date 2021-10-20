import getpass
import os
import psycopg2
from psycopg2 import sql
import pandas as pd

from configobj import ConfigObj
from tqdm import tqdm
from typing import Tuple


__all__ = ['connect_to_database', 'get_id_list',
           'get_database_table_column_name',
           'get_database_table_as_dataframe']


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


def get_database_table_column_name(_conn: psycopg2.extensions.connection,
                                   _table: str) -> list:
    """
    Taken from:
    https://kb.objectrocket.com/postgresql/get-the-column-names-from-a-postgresql-table-with-the-psycopg2-python-adapter-756 # noqa

    defines a function that gets the column names from a PostgreSQL table.

    """
    # declare an empty list for the column names
    columns = []

    # declare cursor objects from the connection
    col_cursor = _conn.cursor()

    # concatenate string for query to get column names
    # SELECT column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'some_table';  # noqa
    col_names_str = "SELECT column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE "
    col_names_str += "table_name = '{}';".format(_table)

    # print the SQL string
    # print("\ncol_names_str:", col_names_str)

    try:
        sql_object = sql.SQL(
            # pass SQL statement to sql.SQL() method
            col_names_str
        ).format(
            # pass the identifier to the Identifier() method
            sql.Identifier(_table)
        )

        # execute the SQL string to get list with col names in a tuple
        col_cursor.execute(sql_object)

        # get the tuple element from the liast
        col_names = (col_cursor.fetchall())

        # print list of tuples with column names
        # print("\ncol_names:", col_names)

        # iterate list of tuples and grab first element
        for tup in col_names:

            # append the col name string to the list
            columns += [tup[0]]

        # close the cursor object to prevent memory leaks
        col_cursor.close()

    except Exception as err:
        print("get_columns_names ERROR:", err)

    # return the list of column names
    return columns


def get_database_table_as_dataframe(_conn: psycopg2.extensions.connection,
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
        print(f"Column names : {df.columns.tolist()}\n")

    else:
        num_entries, col_names = 0, None
        df_iter = pd.read_sql_query(query, _conn, chunksize=_chunk_size)
        for chunk in tqdm(df_iter):
            num_entries += len(chunk)
            if col_names is None:
                col_names = chunk.columns.tolist()
        print(f"Number of entries for {_table} : {num_entries}")
        print(f"Column names : {col_names}\n")
        df = pd.read_sql_query(query, _conn, chunksize=_chunk_size)

    return df


def get_id_list(_conn: psycopg2.extensions.connection,
                _query_schema: str,
                _table: str,
                _id_col_name: str,
                _filter_col: tuple = None,
                _filter_col_val: tuple = None) -> list:
    """Get the list of ids."""

    print(f"Getting {_table} data")

    if _filter_col is None:
        query = _query_schema + f"""
        select {_id_col_name}
        from {_table}
        """

    else:
        assert isinstance(_filter_col_val, tuple)
        query = _query_schema + f"""
        select {_id_col_name}
        from {_table}
        where {_filter_col} in {_filter_col_val}
        """

    df = pd.read_sql_query(query, _conn)
    df.sort_values(_id_col_name, ascending=True, inplace=True)
    df.drop_duplicates(subset=[_id_col_name])

    print(f"Number of entries for {_table} : {df.shape[0]}")

    return df[_id_col_name].tolist()

    # def get_multiple_data_and_save(output_folder,
    #                                patientunitstayid_list=[],
    #                                pid=0):
    #     """
    #     Iterates over `patientunitstayid` and saves entries from all tables
    #     with the similar id into json.
    #     """

    #     query_schema, conn = connect_to_database()

    #     pbar = tqdm(patientunitstayid_list, position=pid+1)
    #     for patientunitstayid in pbar:

    #         time.sleep(1)
    #         pbar.set_description(f"Processing {patientunitstayid}")

    #         json_dict = {}

    #         for table_name in TABLE_LIST:

    #             query = query_schema + """
    #             select *
    #             from {}
    #             where patientunitstayid = {}
    #             """.format(table_name, patientunitstayid)
    #             df = pd.read_sql_query(query, conn)

    #             label = df.columns.to_list()

    #             json_dict[table_name] = {}
    #             for label_i in label:
    #                 json_dict[table_name][label_i] = df[label_i].tolist()

    #         json_path = f"{output_folder}/{patientunitstayid}.json"
    #         with open(json_path, 'w') as json_file:
    #             json.dump(json_dict, json_file)

    #     conn.close()
