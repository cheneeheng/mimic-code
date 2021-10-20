"""Exports data from SQL database into json files. """

import json
import pandas as pd
import time

from tqdm import tqdm

from projects.utils import *


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
