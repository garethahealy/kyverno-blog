#!/usr/bin/env bats

load bats-support-clone
load test_helper/bats-support/load
load test_helper/redhatcop-bats-library/load

setup_file() {
  rm -rf /tmp/rhcop
}

@test "all policies on cluster" {
  tmp=$(split_files "policy/container-image-latest/test_data/unit")

  oc get clusterpolicy -o yaml > clusterpolicies.yml
  clusterpolicies=$(split_files "clusterpolicies.yml")

  cmd="kyverno apply ${clusterpolicies}/clusterpolicies.yml --resource ${tmp}/list.yml"
  run ${cmd}

  print_info "${status}" "${output}" "${cmd}" "${tmp}"
  [ "$status" -eq 1 ]

  echo "lines[2] == ${lines[2]}"
  echo "#lines[@] == ${#lines[@]}"
  [[ "${lines[2]}" == *"1. validate-resources: validation error: Deployment/imageuseslatesttag: one of its containers is using the latest tag for its image, which is an anti-pattern. Rule validate-resources failed at path /spec/template/spec/containers/0/image/"* ]]
  [[ "${#lines[@]}" -eq 4 ]]
}