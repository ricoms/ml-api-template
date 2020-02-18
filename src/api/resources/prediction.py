import json
from pathlib import Path
from dataclasses import dataclass

import falcon
from utils.logger import logger
from utils.model import ProjectModel


@dataclass
class PredictionService:
    """
        A singleton for holding the model. This simply loads
        the model and holds it.
        It has a predict function that does a prediction based
        on the model and the input data.
    """
    def __init__(self, model_base_path: Path):
        self.model = {}
        for model_prefix in Path(model_base_path).glob('*'):
            logger.info(f"Loading model {model_prefix.stem}")
            model = ProjectModel()
            model.load(model_prefix)
            self.model[model_prefix.stem] = model

    def on_post(self, request, response):

        if request.content_type == "application/json":
            payload = json.loads(request.stream.read().decode("utf-8"))
        else:
            raise falcon.HTTPUnsupportedMediaType('json please!')

        ids = []
        X = []
        model_name = "divorce"

        for instance in payload:
            ids.append(instance["id"])
            x = [int(i) for i in instance["features"].split(';')]
            X.append(x)

        preds = self.model[model_name].predict(ids, X)

        logger.info(f'Generated {len(preds)} predictions.')
        response.status = falcon.HTTP_OK
        response.body = json.dumps(preds)
