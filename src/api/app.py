import falcon

from api.resources import PredictionService, HealthCheckResource
from services.logger import set_up_logging


logger = set_up_logging(__name__)


def _extend_api(api):
    api.add_route('/health-check/liveness', HealthCheckResource())
    api.add_route('/invocations', PredictionService())
    #TODO: load model when starting the api
    api.add_route('/health-check/readiness', HealthCheckResource())


logger.info('Starting server.')
app = falcon.API()
_extend_api(app)