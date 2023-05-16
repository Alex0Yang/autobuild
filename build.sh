#!/usr/bin/env bash

set -e

REPO="mritd/autobuild"
TOKEN="${GITHUB_TOKEN:-}"
TARGET="$1"

if [ "${TARGET}" == "alpine" ] || [ "${TARGET}" == "all" ] || [ "${TARGET}" == "" ]; then
    # 触发alpine action
    ALPINE_RESPONSE=$(curl -s -X POST -H "Authorization: token $TOKEN" \
        "https://api.github.com/repos/$REPO/actions/workflows/alpine.yaml/dispatches" \
        -d '{"ref":"main", "inputs": {"trigger": "build"}}')

    if [ -n "$ALPINE_RESPONSE" ]; then
        echo "Alpine workflow triggered: $ALPINE_RESPONSE"
    else
        echo "Alpine workflow triggered with no response"
    fi

    while true; do
        # 从 GitHub API 获取 action 的状态
        ALPINE_STATUS=$(curl -s -H "Authorization: token $TOKEN" \
            "https://api.github.com/repos/$REPO/actions/workflows/alpine.yml/runs" | \
            jq -r '.workflow_runs[0].status')
      
        # 打印日志
        echo "Status of autobuild/alpine action: $ALPINE_STATUS"
      
        # 如果状态为 "completed"，退出循环
        if [ "$ALPINE_STATUS" == "completed" ]; then
            break
        fi
      
        # 等待 3 秒后再次检测
        sleep 3
    done

fi

if [ "${TARGET}" == "all" ] || [ "${TARGET}" == "" ]; then

    # 获取除alpine action和.earthly以外的所有workflow的名称和ID
    WORKFLOWS=$(curl -s -X GET -H "Authorization: token $TOKEN" \
        "https://api.github.com/repos/$REPO/actions/workflows" | \
        jq -r '.workflows[] | select(.path != ".github/workflows/.earthly.yaml" and .name != "mritd/alpine") | "\(.id) \(.name)"')
    
    # 遍历除alpine action和.earthly以外的所有workflow的名称和ID，并触发它们
    while read -r workflow_id workflow_name
    do
        response=$(curl -s -X POST -H "Authorization: token $TOKEN" \
            "https://api.github.com/repos/$REPO/actions/workflows/$workflow_id/dispatches" \
            -d '{"ref":"main", "inputs": {"trigger": "build"}}')
        if [ -n "$response" ]; then
            echo "Workflow $workflow_name ($workflow_id): $response"
        else
            echo "Workflow $workflow_name ($workflow_id) triggered with no response"
        fi
    done <<< "$WORKFLOWS"
fi
