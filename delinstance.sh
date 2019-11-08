zone=$(gcloud compute instances list --filter="name="$HOSTNAME"" --format="value(zone)" --quiet)
gcloud compute instances delete $HOSTNAME --zone=$zone --delete-disks=all --quiet
