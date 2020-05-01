gcloud container clusters create capstone-eks \
  --num-nodes=1 \
  --cluster-version=1.15.11-gke.9 \
  --image-type=COS \
  --labels=project=udacity \
  --region=us-central1
