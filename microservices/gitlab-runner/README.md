
helm install --namespace gitlab gitlab-runner-ui \
  --set gitlabUrl=https://gitlab.project.space/ \
  --set runnerRegistrationToken="..." \
  --set runners.privileged=true \
   gitlab/gitlab-runner

helm install --namespace gitlab gitlab-runner-crawler \
  --set gitlabUrl=https://gitlab.project.space/ \
  --set runnerRegistrationToken="..." \
  --set runners.privileged=true \
   gitlab/gitlab-runner


kubectl create clusterrolebinding gitlab-cluster-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=gitlab:default