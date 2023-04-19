#!/bin/bash

set -e

function delete_vm {
  local NAME=$1
  $(yc compute instance delete --name="$NAME")
}

delete_vm "masterk8s"
delete_vm "worker1"
delete_vm "worker2"
delete_vm "worker3"
delete_vm "worker4"
