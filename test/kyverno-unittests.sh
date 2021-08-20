#!/usr/bin/env bats

load bats-support-clone
load test_helper/bats-support/load
load test_helper/redhatcop-bats-library/load

setup_file() {
  rm -rf /tmp/rhcop
}

update_test_resource_path() {
  tmp="${1}"

  yq --yaml-output --in-place '.resources[] |= gsub("/";"_")' "${tmp}/test.yaml"
}

@test "policy/container-image-latest - validate" {
  cmd="kyverno validate policy/container-image-latest/src.yaml"
  run ${cmd}

  print_info "${status}" "${output}" "${cmd}" "/tmp"
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Policy container-image-latest is valid." ]
  [[ "${#lines[@]}" -eq 2 ]]
}

@test "policy/container-image-latest - test" {
  tmp=$(split_files "policy/container-image-latest")
  update_test_resource_path "${tmp}"

  cmd="kyverno test ${tmp}"
  run ${cmd}

  print_info "${status}" "${output}" "${cmd}" "${tmp}"
  [ "$status" -eq 0 ]
  [[ "${lines[5]}" == *"imageuseslatesttag with container-image-latest/validate-resources"*"Pass"* ]]
  [[ "${#lines[@]}" -eq 7 ]]
}
