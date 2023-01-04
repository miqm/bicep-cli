import yaml
import fileinput

with open(".github/workflows/dependabot_hack.yml", 'r') as dependencyStream:
  workflowDef = yaml.safe_load(dependencyStream)
  steps = workflowDef['jobs']['dependabot_hack']['steps']
  dockerArgs = {}
  for step in steps:
    dependency = str(step['uses']).split('@')
    match dependency[0]:
      case 'azure/bicep': dockerArgs['BICEP_VERSION'] = dependency[1][1:]
      case 'azure/azure-cli':  dockerArgs['CLI_VERSION'] = dependency[1][10:]
      case 'mikefarah/yq':  dockerArgs['YQ_VERSION'] = dependency[1][1:]
      case 'geofffranks/spruce': dockerArgs['SPRUCE_VERSION'] = dependency[1][1:]
      case 'Azure/azure-storage-azcopy':
        dockerArgs['AZCOPY_VERSION'] = version =dependency[1][1:]
        dockerArgs['AZCOPY_VERSION_MAJOR'] = version.split('.')[0]
      case 'tfutils/tfenv':  dockerArgs['TFENV_VERSION'] = dependency[1][1:]
      case 'kubernetes/kubernetes':  dockerArgs['KUBECTL_VERSION'] = dependency[1][1:]
      case 'Azure/kubelogin':  dockerArgs['KUBELOGIN_VERSION'] = dependency[1][1:]
      case 'helm/helm':  dockerArgs['HELM_VERSION'] = dependency[1][1:]
  with fileinput.FileInput('Dockerfile', inplace=True) as file:
    for line in file:
      if line.startswith('ARG'):
        argName = line[4:].split('=')[0].strip()
        line = f'ARG {argName}={dockerArgs[argName]}\n'
      print(line, end='')
