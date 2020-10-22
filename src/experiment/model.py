from abc import ABC, abstractmethod
from dataclasses import dataclass

import joblib
from sklearn import svm
from sklearn.base import BaseEstimator
from sklearn.feature_selection import SelectKBest, f_regression
from sklearn.pipeline import Pipeline

from utils.logger import logger


class MLModel(ABC):

    @property
    @abstractmethod
    def model_id(self) -> str:
        pass

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

    @property
    def model_id(self) -> str:
        return "divorce"

    def save(self, model_prefix):
        self.model_path = model_prefix / self.model_id / 'model.joblib'
        joblib.dump(self.model, self.model_path)
        return self.model_path

    def load(self, model_prefix):
        self.model_path = model_prefix / self.model_id / 'model.joblib'
        try:
            self.model = joblib.load(self.model_path)
        except FileExistsError as e:
            logger.error(e)
        except Exception as e:
            raise e
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

    def train(
        self,
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
