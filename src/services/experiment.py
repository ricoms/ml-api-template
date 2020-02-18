import csv
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split

from utils.logger import logger

from .artifacts import ExperimentArtifacts


@dataclass
class Experiment:
    model: Any
    data_path: Path
    artifacts_handler: ExperimentArtifacts
    training_portion: float = .8
    random_state: int = 42

    def load_data(self):
        data = np.genfromtxt(self.data_path, delimiter=';', skip_header=1)
        self.X, self.y = data[:, :-1], data[:, -1]

    def split_data(self):
        self.X_train, self.X_validation, self.y_train, self.y_validation = train_test_split(
            self.X,
            self.y,
            train_size = self.training_portion,
            random_state = self.random_state,
            stratify = self.y,
        )

    def train(self):
        self.history = self.model.train(
            self.X_train,
            self.y_train,
            self.X_validation,
            self.y_validation,
        )

    def save(self):
        self.artifacts_handler.save()
        self.model.save(self.artifacts_handler.output_prefix)

    def run(self):
        self.load_data()
        self.split_data()

        self.train()

        self.artifacts_handler.generate_artifacts(
            self.history
        )
        self.save()
        self.artifacts_handler.create_package_with_models()
