import pickle
from abc import ABC, abstractmethod
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import joblib
import numpy as np
from sklearn import svm
from sklearn.base import BaseEstimator
from sklearn.feature_selection import SelectKBest, chi2, f_regression
from sklearn.pipeline import Pipeline

from utils.files import JsonFile, PickleFile
from utils.logger import logger


class MLModel(ABC):

    @abstractmethod
    def save(self):
        pass

    @abstractmethod
    def load(self):
        pass

    @abstractmethod
    def predict(self, data):
        pass


@dataclass
class ProjectModel(MLModel):
    model: BaseEstimator = None

    def save(self, model_prefix):
        self.model_path = model_prefix / 'model.joblib'
        joblib.dump(self.model, self.model_path)
        return self.model_path

    def load(self, model_prefix):
        self.model_path = model_prefix / 'model.joblib'
        try:
            self.model = joblib.load(self.model_path)
        except FileExistsError as e:
            logger.error(e)
        except:
            raise
        return self.model

    def __build_model(self):
        anova_filter = SelectKBest(f_regression, k=5)
        clf = svm.SVC(kernel='linear')
        anova_svm = Pipeline(
            [
                ('anova', anova_filter),
                ('svc', clf)
            ]
        )
        self.model = anova_svm.set_params(
            anova__k=10,
            svc__C=.1,
        )

    def train(self,
        X_train,
        y_train,
        X_validation,
        y_validation,
    ):
        self.__build_model()

        self.model.fit(
            X_train,
            y_train,
        )
        score = self.model.score(X_validation, y_validation)
        metrics = {
            'score': score,
        }
        return metrics

    def predict(self, ids, X):
        prediction = self.model.predict(X)
        return {i: pred for i, pred in zip(ids, prediction)}
