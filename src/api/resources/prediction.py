import json

import falcon

from services.logger import set_up_logging
from services.model import load_model, predict
from services.cloud import get_artifacts


logger = set_up_logging(__name__)


class PredictionService:
    """
        A singleton for holding the model. This simply loads
        the model and holds it.
        It has a predict function that does a prediction based
        on the model and the input data.
    """
    model = None # Where we keep the model when it's loaded

    def get_model(self):
        """Get the model object for this instance, loading it if
        it's not already loaded."""
        
        if self.model == None:
            weights_file = str(constants.MODEL_PATH / "model.joblib")
            if download(weights_file, 'output/model.joblib'):
                logger.info('Begin server with weights_file: {}'.format(weights_file))
                self.model = load_model(weights_file)
                logger.info('Succesfully load model {}'.format(weights_file))
            else:
                logger.info('No weights_file available to begin server.')
                return None         
        return self.model

    def on_post(self, request, response):

        if request.content_type == "text/csv":
            payload = request.stream.read().decode("utf-8")
        else:
            raise falcon.HTTPUnsupportedMediaType('csv please!')

        clf = self.get_model()
        if clf is None:
            response.status = falcon.HTTP_418
            response.body = json.dumps({'error': 'weights_file not available!'})
            raise falcon.HTTPServiceUnavailable('weights_file not available!')

        preds = predict(payload, clf)
        logger.info('Generated prediction.')

        response.status = falcon.HTTP_OK
        response.body = json.dumps(preds)