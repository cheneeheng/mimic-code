import os
import pandas as pd
import numpy as np


__all__ = ['save_info_dsv', 'save_data_dsv',
           'load_info_dsv', 'load_data_dsv',
           'InfoTable', 'DataTable']


def save_dsv(path: str, data: pd.DataFrame):
    save_dir, _ = os.path.split(path)
    os.makedirs(save_dir, exist_ok=True)
    data.to_csv(path, na_rep='', sep='$', index=False)


def load_dsv(path: str):
    assert os.path.exists(path), path
    return pd.read_csv(path, sep='$')


def save_info_dsv(data_dir: str, stay_id: int, data: pd.DataFrame) -> dict:
    save_path = os.path.join(data_dir, 'info_'+str(stay_id)+'.dsv')
    save_dsv(save_path, data)


def save_data_dsv(data_dir: str, stay_id: int, data: pd.DataFrame) -> dict:
    save_path = os.path.join(data_dir, 'data_'+str(stay_id)+'.dsv')
    save_dsv(save_path, data)


def load_info_dsv(data_dir: str, stay_id: int) -> dict:
    save_path = os.path.join(data_dir, 'info_'+str(stay_id)+'.dsv')
    data = load_dsv(save_path).to_dict()
    data = {k: v if len(v) > 0 else np.array([], dtype=int)
            for k, v in data.items()}
    return data


def load_data_dsv(data_dir: str, stay_id: int) -> dict:
    save_path = os.path.join(data_dir, 'data_'+str(stay_id)+'.dsv')
    data = load_dsv(save_path).to_dict()
    data = {k: v if len(v) > 0 else np.array([], dtype=int)
            for k, v in data.items()}
    return data


class InfoTable(object):

    col_entries = ['uid', 'value']

    def __init__(self) -> None:
        self.data = {i: np.array([], dtype=int) for i in self.col_entries}

    def sort_uid(self) -> None:
        sorted_ids = np.argsort(self.data['uid'])
        for k in self.data.keys():
            self.data[k] = self.data[k][sorted_ids]

    def append(self, **kwargs) -> None:
        for i in kwargs:
            assert i in self.col_entries
        assert len(kwargs) == len(self.col_entries)

        self.data = {i: np.append(self.data[i], kwargs[i])
                     for i in self.col_entries}


class DataTable(object):

    col_entries = ['uid', 'value', 'unit', 'rate', 'rate_unit',
                   'category', 'specimen_id', 'starttime', 'endtime']

    def __init__(self) -> None:
        self.data = {i: np.array([], dtype=int) for i in self.col_entries}

    def sort_uid(self) -> None:
        sorted_ids = np.argsort(self.data['uid'])
        for k in self.data.keys():
            self.data[k] = self.data[k][sorted_ids]

    def sort_starttime(self) -> None:
        sorted_ids = np.argsort(self.data['starttime'])
        for k in self.data.keys():
            self.data[k] = self.data[k][sorted_ids]

    def remove_duplicates(self) -> None:
        stacked_arr = np.stack([i for _, i in self.data.items()]).astype(str)
        stacked_arr = np.unique(stacked_arr, axis=1)
        self.data = {i: stacked_arr[idx].astype(self.data[i].dtype)
                     for idx, i in enumerate(self.col_entries)}

    def remove_null_value(self) -> None:
        non_null_mask = ~pd.isnull(self.data['value'])
        for k in self.data:
            self.data[k] = self.data[k][non_null_mask]

    def concatenate(self, x: dict) -> None:
        assert len(x) == len(self.col_entries)

        self.data = {i: np.concatenate([self.data[i], x[i]])
                     for i in self.col_entries}

    def append(self, **kwargs) -> None:
        for i in kwargs:
            assert i in self.col_entries
        assert len(kwargs) == len(self.col_entries)

        self.data = {i: np.append(self.data[i], kwargs[i])
                     for i in self.col_entries}
