from dataclasses import dataclass

import falcon

from api.resources import HealthCheckResource, PredictionService
from utils.logger import logger

logger.info('Starting server.')


@dataclass
class MLAPI:
    model_base_path: str

    def __extend_api(self):
        logger.info(f"Set /health-check/liveness route")
        self.api.add_route(
            '/health-check/liveness',
            HealthCheckResource()
        )
        logger.info(f"Set /invocations route")
        self.api.add_route(
            '/invocations',
            PredictionService(self.model_base_path)
        )
        logger.info(f"Set /ping route")
        self.api.add_route(
            '/ping',
            HealthCheckResource()
        )

    def setup(self):
        logger.info('Starting server.')
        self.api = falcon.API()
        self.__extend_api()
        return self.api
