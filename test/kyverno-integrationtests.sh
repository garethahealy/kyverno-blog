#!/usr/bin/env bats

load bats-support-clone
load test_helper/bats-support/load
load test_helper/redhatcop-bats-library/load

setup_file() {
  oc api-versions --request-timeout=5s || return $?
  oc cluster-info || return $?

  export project_name="kyverno-undertest-$(date +'%d%m%Y-%H%M%S')"

  rm -rf /tmp/rhcop
  oc process --local -f test/resources/namespace-under-test.yml -p=PROJECT_NAME=${project_name} | oc create -f -
}

teardown_file() {
  if [[ -n ${project_name} ]]; then
    oc delete namespace/${project_name}
  fi
}

teardown() {
  if [[ -n "${tmp}" ]]; then
    oc delete -f "${tmp}" --ignore-not-found=true --wait=true > /dev/null 2>&1
  fi
}

@test "policy/container-image-latest" {
  tmp=$(split_files "policy/container-image-latest/test_data/unit")

  cmd="oc create -f ${tmp} -n ${project_name}"
  run ${cmd}

  print_info "${status}" "${output}" "${cmd}" "${tmp}"
  [ "$status" -eq 1 ]
  [[ "${lines[0]}" == *"admission webhook \"validate.kyverno.svc\" denied the request"* ]]
  [[ "${lines[1]}" == *"imageuseslatesttag was blocked due to the following policies"* ]]
  [[ "${lines[2]}" == *"container-image-latest"* ]]
  [[ "${#lines[@]}" -eq 6 ]]
}
