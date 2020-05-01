gcloud container clusters create capstone-eks \
  --num-nodes=1 \
  --cluster-version=1.14.10-gke.27 \
  --image-type=COS \
  --labels=project=udacity \
  --region=us-central1
