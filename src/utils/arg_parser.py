import argparse
import configparser
import datetime
import multiprocessing
import os
import time
from abc import ABC, abstractmethod
from pathlib import Path
from typing import Any, Dict


class ArgParser(ABC):

    def __init__(self):
        environment = os.environ.get("ENVIRON", "DOCKER")
        config = configparser.ConfigParser()
        config.read('config.ini')
        config = config[environment]

        self.proj_prefix = Path(config.get("PROJ_PREFIX", "/opt/program"))
        self.ml_prefix = Path(config.get("ML_PREFIX", "/opt/ml"))
        self.output_prefix = self.ml_prefix / 'output'
        self.data_prefix = self.ml_prefix / 'input/data/'
        self.config_prefix = self.ml_prefix / 'input/config'
        self.aws_param_file = self.ml_prefix / "input/config/hyperparameters.json"
        self.run_tag = datetime.datetime \
            .fromtimestamp(time.time()) \
            .strftime('%Y-%m-%d-%H%M%S')

    @abstractmethod
    def get_arguments(self) -> Dict[str, Any]:
        pass


class LocalArgParser(ArgParser):

    def get_arguments(self) -> Dict[str, Any]:
        parser = argparse.ArgumentParser()
        parser.add_argument(
            '--data_path',
            default=self.data_prefix / 'data.csv',
            type=Path,
            help=f"Path to a local storage (default: \
                '{str(self.data_prefix / 'training')}')",
        )
        parser.add_argument(
            '--output_base_path',
            default=str(self.output_prefix),
            type=Path,
            help=f"Path to a local storage (default: \
                '{str(self.output_prefix)}')",
        )
        parser.add_argument(
            '--project_name',
            default="",
            type=str,
            help="Project name (default: '')",
        )
        parser.add_argument(
            '--run_tag',
            default=self.run_tag,
            type=str,
            help=f"Run ID (default: '{self.run_tag}')",
        )
        args = parser.parse_args()

        return args


class APIArgParser(ArgParser):

    def get_arguments(self) -> Dict[str, Any]:
        parser = argparse.ArgumentParser()
        parser.add_argument(
            '--model_base_path',
            default=self.ml_prefix,
            type=Path,
            help=f"Path to a local storage (default: \
                '{str(self.ml_prefix)}')",
        )
        parser.add_argument(
            '--project_name',
            default="",
            type=str,
            help="Project name (default: '')",
        )
        parser.add_argument(
            '--run_tag',
            default=self.run_tag,
            type=str,
            help=f"Run ID (default: '{self.run_tag}')",
        )
        cpu_count = multiprocessing.cpu_count()
        parser.add_argument(
            '--model_server_workers',
            default=cpu_count,
            type=int,
            help=f" Number of model server workers (default: '{cpu_count}')",
        )
        parser.add_argument(
            '--model_server_timeout',
            default=60,
            type=int,
            help=f"Number of model server workers (default: 60)",
        )
        args = parser.parse_args()

        return args
