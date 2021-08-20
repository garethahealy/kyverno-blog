#!/usr/bin/env bats

load bats-support-clone
load test_helper/bats-support/load
load test_helper/redhatcop-bats-library/load

setup_file() {
  export project_name="kyverno-undertest-$(date +'%d%m%Y-%H%M%S')"

  rm -rf /tmp/rhcop
  oc process --local -f test/resources/namespace-under-test.yml -p=PROJECT_NAME=${project_name} | oc create -f -
}

teardown_file() {
  if [[ -n ${project_name} ]]; then
    oc delete namespace/${project_name}
  fi
}

get_clusterpolicyreport_json() {
  echo "${2}" > ${1}/clusterpolicyreport.log
  cluster_policy_report=$(sed -n '/^apiVersion/,$p' ${1}/clusterpolicyreport.log | yq '.')

  if [[ -z "${cluster_policy_report}" ]] ; then
    batslib_err "# sed -n '/^apiVersion/,$p' ${1}/clusterpolicyreport.log | yq '.'"
    fail "# FATAL-ERROR: get_clusterpolicyreport_json: is empty" || return $?
  fi

  echo "${cluster_policy_report}"
}

get_value_from_clusterpolicyreport() {
  cluster_policy_report="${1}"
  key="${2}"

  value=$(echo "${cluster_policy_report}" | jq -r "${key}")

  if [[ -z "${value}" ]] ; then
    batslib_err "# echo "${cluster_policy_report}" | jq -r "${key}""
    fail "# FATAL-ERROR: get_value_from_clusterpolicyreport: value is empty" || return $?
  fi

  echo "${value}"
}

@test "policy/container-image-latest - cluster" {
  # Make sure no policies exist, or we wont be able to create the resource
  oc delete clusterpolicy/container-image-latest

  tmp=$(split_files "policy/container-image-latest/test_data/unit")
  oc create -f ${tmp}/list.yml -n ${project_name}

  cmd="kyverno apply policy/container-image-latest/src.yaml --cluster --namespace ${project_name} --policy-report"
  run ${cmd}

  print_info "${status}" "${output}" "${cmd}" "${tmp}"
  [ "$status" -eq 0 ]

  clusterpolicyreport_json=$(get_clusterpolicyreport_json "${tmp}" "${output}")
  failcount=$(get_value_from_clusterpolicyreport "${clusterpolicyreport_json}" ".summary.fail")
  resultsmessage=$(get_value_from_clusterpolicyreport "${clusterpolicyreport_json}" ".results[0].message")

  [[ "${failcount}" == "1" ]]
  [[ "${resultsmessage}" == "validation error: Deployment/imageuseslatesttag: one of its containers is using the latest tag for its image, which is an anti-pattern. Rule validate-resources failed at path /spec/template/spec/containers/0/image/" ]]
}
