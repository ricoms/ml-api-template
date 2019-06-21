import zipfile

import boto3
from botocore.exceptions import ClientError

import constants
from services.logger import set_up_logging


logger = set_up_logging(__name__)


def get_data():
    s3 = boto3.client('s3')
    file_path = constants.INPUT_PATH / 'train.zip'
    logger.info(f"Getting data from: {BUCKET}")
    with open(file_path, 'wb') as data:
        s3.download_fileobj(
            BUCKET,
            'input/train.zip',
            data)
    
    if file_path.exists():
        zip_ref = zipfile.ZipFile(file_path, 'r')
        zip_ref.extractall(constants.INPUT_PATH / 'training/')
        zip_ref.close()
    else:
        raise ValueError(f"{file_path} isn't a file!")


def save_artifacts():
    s3 = boto3.client('s3')
    try:
        response = s3.upload_file(
            str(constants.MODEL_PATH / "model.joblib"),
            BUCKET,
            'output/model.joblib')
    except ClientError as e:
        logging.error(e)
        return False
    return True


def get_artifacts(file_path):
    if file_path.exists():
        return 1
    else:
        s3 = boto3.client('s3')
        logger.info(f"Getting data from: {BUCKET}")
        
        with open(file_path, 'wb') as data:
            s3.download_fileobj(
                BUCKET,
                'output/model.joblib',
                data)        
        return 1