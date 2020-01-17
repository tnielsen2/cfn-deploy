#!/bin/bash

set -eux
set -o pipefail

STACK_NAME="test"

assert_string_in() {
    needle=$1
    haystack=$2
    if [[ $haystack != *$needle* ]] ; then
        echo "Couldn't find $needle in:" >&2
        echo "$haystack" >&2
        exit 1
    else
        echo "Found '$haystack'"
    fi
}

cd "$(dirname "$0")/.."

echo "==> Build image"
image_id=$(docker build -q .)
echo "Image ID is $image_id"

echo "==> Test 1: happy path"
if ! output="$(docker run --rm \
    -e "INPUT_STACKNAME=$STACK_NAME" \
    -e INPUT_TEMPLATEFILE=test/stack.yml \
    -v "$(pwd)/test:/test" \
    -e "AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" \
    -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
    -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
    -e INPUT_PARAMETERS="Name=TestNameNew" \
    -e INPUT_PARAMETERFILE="test/params.txt" \
    "$image_id")" ; then
    echo "Command failed!" >&2
    exit 1
else
    assert_string_in "::set-output name=cf_output_SecurityGroup::" "$output"
    assert_string_in "::set-output name=cf_output_SecurityGroupId::" "$output"
fi

echo "==> Delete stack"
aws cloudformation delete-stack --stack-name "$STACK_NAME"

# echo "==> Test 2: Missing params file"

echo "==> Testing complete"

echo "==> Delete image"
docker rmi "$image_id"
