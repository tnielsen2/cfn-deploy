#!/usr/bin/env bash

# Exit on error. Append "|| true" if you expect an error.
set -o errexit  # same as -e
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch if the pipe function fails
set -o pipefail

debug() {
    echo "::debug ::$*"
}

# Build the commandline
deploy_cmd=("aws"
    "cloudformation" "deploy"
    "--no-fail-on-empty-changeset"
    "--stack-name" "$INPUT_STACKNAME"
    "--template-file" "$INPUT_TEMPLATEFILE"
    )
params=()
if [[ -n ${INPUT_PARAMETERS:-} ]]; then
    read -r -a params <<< "$INPUT_PARAMETERS"
fi
if [[ -n ${INPUT_PARAMETERFILE:-} ]] ; then
    if ! [[ -f $INPUT_PARAMETERFILE ]] ; then
        echo "::error file=$INPUT_PARAMETERFILE::File not found."
        exit 1
    fi
    line_no=0 # purely for error reporting
    while read -r line ; do
        line_no=$((line_no+1))
        if ! [[ $line = *=* ]] ; then
            echo "::error file=$INPUT_PARAMETERFILE,line=$line_no,col=1::Line not in key=val format."
            exit 1
        fi
        params+=("$line")
    done < "$INPUT_PARAMETERFILE"
fi
if [[ ${#params[@]} -gt 0 ]] ; then
    deploy_cmd+=("--parameter-overrides" "${params[@]}")
fi
if [[ -n ${INPUT_CAPABILITIES:-} ]] ; then
    deploy_cmd+=("--capabilities" "$INPUT_CAPABILITIES")
fi
if [[ -n ${INPUT_NOEXECUTECHANGESET} ]] ; then
    deploy_cmd+=("--no-execute-changeset")
fi

debug "Running: ${deploy_cmd[*]}"
"${deploy_cmd[@]}"

# Add outputs
# The stack description has no "Outputs" key if there are no outputs, hence this
# defensive construction.
outputs=$(aws cloudformation describe-stacks --stack-name "$INPUT_STACKNAME" | jq -cr '.Stacks[0].Outputs')
if [[ $outputs != null ]] ; then
    echo "$outputs" | jq -c '.[]' | while read -r line; do
        key=$(echo "$line" | jq -r '.OutputKey')
        value=$(echo "$line" | jq -r '.OutputValue')
        debug "Set output cf_output_$key=$value"
        echo "::set-output name=cf_output_$key::$value"
    done
fi
