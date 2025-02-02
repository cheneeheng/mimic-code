import os
import pandas as pd
import numpy as np


__all__ = ['save_dsv', 'load_dsv',
           #    'save_info_dsv', 'save_data_dsv',
           'load_info_dsv', 'load_data_dsv',
           'InfoTable', 'DataTable']


def save_dsv(path: str, data: pd.DataFrame):
    save_dir, _ = os.path.split(path)
    os.makedirs(save_dir, exist_ok=True)
    data.to_csv(path, na_rep='', sep='$', index=False)


def load_dsv(path: str) -> pd.DataFrame:
    assert os.path.exists(path), path
    try:
        df = pd.read_csv(path, sep='$')
    except:  # noqa
        raise ValueError("Error reading :", path)
    return df


# def save_info_dsv(data_dir: str, stay_id: int, data: pd.DataFrame) -> dict:
#     save_path = os.path.join(data_dir, 'info_'+str(stay_id)+'.dsv')
#     save_dsv(save_path, data)


# def save_data_dsv(data_dir: str, stay_id: int, data: pd.DataFrame) -> dict:
#     save_path = os.path.join(data_dir, 'data_'+str(stay_id)+'.dsv')
#     save_dsv(save_path, data)


def load_info_dsv(save_path: str) -> dict:
    data = load_dsv(save_path).to_dict('list')
    data = {k: np.array(v) if len(v) > 0 else np.array([], dtype=int)
            for k, v in data.items()}
    return data


def load_data_dsv(save_path: str) -> dict:
    data = load_dsv(save_path).to_dict('list')
    data = {k: np.array(v) if len(v) > 0 else np.array([], dtype=int)
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

    col_entries = [
        'uid',
        'value', 'unit',
        'rate', 'rate_unit',
        'lower_range', 'upper_range',
        'category',
        'specimen_id',
        'starttime', 'endtime']

    def __init__(self) -> None:
        self.data = {i: np.array([], dtype=int) for i in self.col_entries}

    def _append_kwarg_check(self, kwargs: dict, key: str):
        value = kwargs.get(key, None)
        if key == 'unit':
            if isinstance(value, str):
                value.replace(' ', '')
        elif key == 'starttime' and value is not None:
            value = str(value)
        elif key == 'endtime' and value is not None:
            value = str(value)
        return None if value == '' else value

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

    # def concatenate(self, x: dict) -> None:
    #     assert len(x) == len(self.col_entries)

    #     self.data = {i: np.concatenate([self.data[i], x[i]])
    #                  for i in self.col_entries}

    def append(self, **kwargs) -> None:
        for k in kwargs:
            assert k in self.col_entries

        try:
            self.data = {
                k: np.append(self.data[k], self._append_kwarg_check(kwargs, k))
                for k in self.col_entries
            }
        except:  # noqa
            raise ValueError(f"{self.data.keys()}")
