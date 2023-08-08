name: mritd/REPLACE_NAME

on:
  schedule:
    - cron: '0 8 * * 1'
  workflow_dispatch:
    inputs:
      trigger:
        description: 'Manually trigger'
        required: true
        type: choice
        options:
          - build

env:
  FORCE_COLOR: 1
  DOCKERHUB_USERNAME: ${{ secrets.DOCKERHUB_USERNAME }}
  DOCKERHUB_PASSWORD: ${{ secrets.DOCKERHUB_PASSWORD }}

jobs:
  REPLACE_NAME:
    runs-on: ubuntu-22.04
    #concurrency: docker-image
    steps:
    - name: Init Earthly
      uses: mritd/init-earthly-action@main
    - name: Earthly Build
      working-directory: ${{ github.job }}
      run: earthly --allow-privileged --push +all